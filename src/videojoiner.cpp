/*
  VideoJoiner — GPLv2 or later, like the rest of the project.
*/
#include "videojoiner.h"

#include <QDebug>
#include <QFile>
#include <QVector>
#include <functional>

#include <gst/gst.h>

namespace {

struct Segment
{
    GstPad *vpad = nullptr; // concat request pads, in playback order
    GstPad *apad = nullptr;
    GstPad *vqueue = nullptr; // per-stream queue sinks in front of them
    GstPad *aqueue = nullptr;
    bool vlinked = false;
    bool alinked = false;
    GstClockTime offset = 0; // position in the joined timeline
    GstClockTime videoDuration = GST_CLOCK_TIME_NONE;
    bool trimAudio = false;
};

// camerabin recordings end with ~1 s more audio than video; that tail would
// delay every following segment's audio, so inner segments are cut at the
// video's end.
GstPadProbeReturn trimAudioProbe(GstPad *, GstPadProbeInfo *info, gpointer ud)
{
    Segment *seg = static_cast<Segment *>(ud);
    GstBuffer *buf = GST_PAD_PROBE_INFO_BUFFER(info);
    if (buf && GST_BUFFER_PTS_IS_VALID(buf) && GST_CLOCK_TIME_IS_VALID(seg->videoDuration)
        && GST_BUFFER_PTS(buf) >= seg->videoDuration)
        return GST_PAD_PROBE_DROP;
    return GST_PAD_PROBE_OK;
}

void onPadAdded(GstElement *, GstPad *pad, gpointer ud)
{
    Segment *seg = static_cast<Segment *>(ud);
    GstCaps *caps = gst_pad_get_current_caps(pad);
    if (!caps)
        caps = gst_pad_query_caps(pad, nullptr);
    if (!caps)
        return;
    const gchar *name = gst_structure_get_name(gst_caps_get_structure(caps, 0));
    GstPad *target = nullptr;
    if (g_str_has_prefix(name, "video/") && !seg->vlinked) {
        target = seg->vqueue;
        seg->vlinked = true;
    } else if (g_str_has_prefix(name, "audio/") && !seg->alinked) {
        target = seg->aqueue;
        seg->alinked = true;
        if (seg->trimAudio)
            gst_pad_add_probe(pad, GST_PAD_PROBE_TYPE_BUFFER, trimAudioProbe, seg, nullptr);
    }
    gst_caps_unref(caps);
    if (!target)
        return;
    gst_pad_set_offset(pad, (gint64)seg->offset);
    if (gst_pad_link(pad, target) != GST_PAD_LINK_OK)
        qWarning() << "VideoJoiner: linking" << name << "failed";
}

// Video track duration (moov/trak/mdia: hdlr 'vide' + mdhd), or NONE.
GstClockTime videoTrackDuration(const QString &path)
{
    QFile f(path);
    if (!f.open(QIODevice::ReadOnly))
        return GST_CLOCK_TIME_NONE;
    auto be32 = [](const QByteArray &b, int o) {
        return quint32((uchar)b[o]) << 24 | quint32((uchar)b[o + 1]) << 16
             | quint32((uchar)b[o + 2]) << 8 | quint32((uchar)b[o + 3]);
    };
    auto be64 = [&](const QByteArray &b, int o) {
        return quint64(be32(b, o)) << 32 | be32(b, o + 4);
    };
    qint64 pos = 0, size = f.size();
    QByteArray moov;
    while (pos + 8 <= size) {
        f.seek(pos);
        QByteArray hdr = f.read(16);
        if (hdr.size() < 8)
            break;
        quint64 bsize = be32(hdr, 0);
        int hlen = 8;
        if (bsize == 1) {
            bsize = be64(hdr, 8);
            hlen = 16;
        } else if (bsize == 0) {
            bsize = size - pos;
        }
        if (hdr.mid(4, 4) == "moov") {
            f.seek(pos + hlen);
            moov = f.read(bsize - hlen);
            break;
        }
        pos += bsize;
    }
    if (moov.isEmpty())
        return GST_CLOCK_TIME_NONE;

    std::function<GstClockTime(int, int)> walk = [&](int off, int end) -> GstClockTime {
        bool isVideo = false;
        GstClockTime dur = GST_CLOCK_TIME_NONE;
        while (off + 8 <= end) {
            quint64 bsize = be32(moov, off);
            int hlen = 8;
            if (bsize == 1) {
                bsize = be64(moov, off + 8);
                hlen = 16;
            } else if (bsize == 0) {
                bsize = end - off;
            }
            const QByteArray type = moov.mid(off + 4, 4);
            const int body = off + hlen;
            if (type == "trak" || type == "mdia") {
                GstClockTime d = walk(body, off + bsize);
                if (GST_CLOCK_TIME_IS_VALID(d))
                    return d;
            } else if (type == "hdlr") {
                isVideo = moov.mid(body + 8, 4) == "vide";
            } else if (type == "mdhd") {
                const int version = (uchar)moov[body];
                quint32 timescale;
                quint64 duration;
                if (version == 1) {
                    timescale = be32(moov, body + 20);
                    duration = be64(moov, body + 24);
                } else {
                    timescale = be32(moov, body + 12);
                    duration = be32(moov, body + 16);
                }
                if (timescale)
                    dur = gst_util_uint64_scale(duration, GST_SECOND, timescale);
            }
            off += bsize;
        }
        return isVideo ? dur : GST_CLOCK_TIME_NONE;
    };
    return walk(0, moov.size());
}

// A segment lacking a stream would stall its concat pad forever.
void onNoMorePads(GstElement *, gpointer ud)
{
    Segment *seg = static_cast<Segment *>(ud);
    if (!seg->vlinked) {
        seg->vlinked = true;
        gst_pad_send_event(seg->vpad, gst_event_new_eos());
    }
    if (!seg->alinked) {
        seg->alinked = true;
        gst_pad_send_event(seg->apad, gst_event_new_eos());
    }
}

GstElement *make(const char *factory, GstElement *bin, QString *error)
{
    GstElement *e = gst_element_factory_make(factory, nullptr);
    if (!e) {
        if (error->isEmpty())
            *error = QStringLiteral("GStreamer element '%1' missing").arg(QString::fromLatin1(factory));
        return nullptr;
    }
    gst_bin_add(GST_BIN(bin), e);
    return e;
}

} // namespace

class VideoJoiner::JoinThread : public QThread
{
public:
    QStringList segments;
    QString output;
    bool ok = false;
    QString error;

    void run() override
    {
        gst_init(nullptr, nullptr);
        GstElement *pipe = gst_pipeline_new("advcam-joiner");

        GstElement *vcat = make("concat", pipe, &error);
        GstElement *acat = make("concat", pipe, &error);
        GstElement *vparse = make("h264parse", pipe, &error);
        GstElement *aparse = make("aacparse", pipe, &error);
        GstElement *vq = make("queue", pipe, &error);
        GstElement *aq = make("queue", pipe, &error);
        GstElement *mux = make("mp4mux", pipe, &error);
        GstElement *sink = make("filesink", pipe, &error);
        if (!error.isEmpty()) {
            gst_object_unref(pipe);
            return;
        }
        g_object_set(sink, "location", output.toUtf8().constData(), nullptr);
        // By name: the queues have no caps yet, a plain link could hand
        // audio a video pad.
        GstPad *muxV = gst_element_get_request_pad(mux, "video_%u");
        GstPad *muxA = gst_element_get_request_pad(mux, "audio_%u");
        GstPad *vqSrc = gst_element_get_static_pad(vq, "src");
        GstPad *aqSrc = gst_element_get_static_pad(aq, "src");
        const bool linked = muxV && muxA
            && gst_element_link_many(vcat, vparse, vq, nullptr)
            && gst_element_link_many(acat, aparse, aq, nullptr)
            && gst_pad_link(vqSrc, muxV) == GST_PAD_LINK_OK
            && gst_pad_link(aqSrc, muxA) == GST_PAD_LINK_OK
            && gst_element_link(mux, sink);
        if (vqSrc) gst_object_unref(vqSrc);
        if (aqSrc) gst_object_unref(aqSrc);
        auto releaseMuxPads = [&]() {
            if (muxV) { gst_element_release_request_pad(mux, muxV); gst_object_unref(muxV); }
            if (muxA) { gst_element_release_request_pad(mux, muxA); gst_object_unref(muxA); }
        };
        if (!linked) {
            error = QStringLiteral("GStreamer: linking the join pipeline failed");
            releaseMuxPads();
            gst_object_unref(pipe);
            return;
        }

        // Segments are placed by pad offsets: chaining running times per
        // stream would drift, video and audio of a recording end apart.
        g_object_set(vcat, "adjust-base", FALSE, nullptr);
        g_object_set(acat, "adjust-base", FALSE, nullptr);

        QVector<Segment *> segs;
        GstClockTime offset = 0;
        for (int i = 0; i < segments.size() && error.isEmpty(); ++i) {
            const QString &path = segments.at(i);
            GstElement *src = make("filesrc", pipe, &error);
            GstElement *demux = make("qtdemux", pipe, &error);
            // Without these a waiting demuxer deadlocks the muxer.
            GstElement *vq2 = make("queue", pipe, &error);
            GstElement *aq2 = make("queue", pipe, &error);
            if (!error.isEmpty())
                break;
            g_object_set(src, "location", path.toUtf8().constData(), nullptr);
            for (GstElement *q : {vq2, aq2})
                g_object_set(q, "max-size-buffers", 0u, "max-size-time", (guint64)0,
                             "max-size-bytes", 16u * 1024 * 1024, nullptr);
            gst_element_link(src, demux);
            Segment *seg = new Segment;
            seg->vpad = gst_element_get_request_pad(vcat, "sink_%u");
            seg->apad = gst_element_get_request_pad(acat, "sink_%u");
            seg->vqueue = gst_element_get_static_pad(vq2, "sink");
            seg->aqueue = gst_element_get_static_pad(aq2, "sink");
            GstPad *vqOut = gst_element_get_static_pad(vq2, "src");
            GstPad *aqOut = gst_element_get_static_pad(aq2, "src");
            gst_pad_link(vqOut, seg->vpad);
            gst_pad_link(aqOut, seg->apad);
            gst_object_unref(vqOut);
            gst_object_unref(aqOut);

            seg->offset = offset;
            seg->videoDuration = videoTrackDuration(path);
            seg->trimAudio = i < segments.size() - 1;
            if (!GST_CLOCK_TIME_IS_VALID(seg->videoDuration)) {
                error = QStringLiteral("cannot read the video duration of %1").arg(path);
                segs.append(seg);
                break;
            }
            qInfo() << "VideoJoiner: segment" << i << path << "video"
                    << (double)seg->videoDuration / GST_SECOND << "s at"
                    << (double)offset / GST_SECOND << "s";
            offset += seg->videoDuration;
            segs.append(seg);
            g_signal_connect(demux, "pad-added", G_CALLBACK(onPadAdded), seg);
            g_signal_connect(demux, "no-more-pads", G_CALLBACK(onNoMorePads), seg);
        }

        if (error.isEmpty()) {
            gst_element_set_state(pipe, GST_STATE_PLAYING);
            GstBus *bus = gst_element_get_bus(pipe);
            GstMessage *msg = gst_bus_timed_pop_filtered(
                bus, 20 * 60 * GST_SECOND,
                GstMessageType(GST_MESSAGE_ERROR | GST_MESSAGE_EOS));
            if (!msg) {
                error = QStringLiteral("GStreamer: joining timed out");
            } else if (GST_MESSAGE_TYPE(msg) == GST_MESSAGE_ERROR) {
                GError *err = nullptr;
                gchar *dbg = nullptr;
                gst_message_parse_error(msg, &err, &dbg);
                error = QStringLiteral("GStreamer: %1").arg(QString::fromUtf8(err ? err->message : "error"));
                qWarning() << "VideoJoiner:" << error << (dbg ? dbg : "");
                if (err) g_error_free(err);
                g_free(dbg);
            } else {
                ok = true;
            }
            if (msg)
                gst_message_unref(msg);
            gst_object_unref(bus);
        }

        gst_element_set_state(pipe, GST_STATE_NULL);
        releaseMuxPads();
        for (Segment *seg : segs) {
            gst_element_release_request_pad(vcat, seg->vpad);
            gst_element_release_request_pad(acat, seg->apad);
            gst_object_unref(seg->vpad);
            gst_object_unref(seg->apad);
            gst_object_unref(seg->vqueue);
            gst_object_unref(seg->aqueue);
            delete seg;
        }
        gst_object_unref(pipe);
    }
};

VideoJoiner::VideoJoiner(QObject *parent)
    : QObject(parent)
{
}

VideoJoiner::~VideoJoiner()
{
    if (m_thread) {
        m_thread->wait();
        delete m_thread;
    }
}

void VideoJoiner::join(const QStringList &segments, const QString &output)
{
    if (m_thread) {
        emit finished(output, false, QStringLiteral("a join is already running"));
        return;
    }
    if (segments.size() < 2) {
        emit finished(output, false, QStringLiteral("nothing to join"));
        return;
    }
    qInfo() << "VideoJoiner: joining" << segments.size() << "segments into" << output;
    m_thread = new JoinThread;
    m_thread->segments = segments;
    m_thread->output = output;
    connect(m_thread, &QThread::finished, this, &VideoJoiner::onThreadFinished);
    emit busyChanged();
    m_thread->start();
}

bool VideoJoiner::renameFile(const QString &from, const QString &to)
{
    QFile::remove(to);
    return QFile::rename(from, to);
}

void VideoJoiner::onThreadFinished()
{
    JoinThread *t = m_thread;
    m_thread = nullptr;
    emit busyChanged();
    if (t->ok)
        qInfo() << "VideoJoiner: done" << t->output;
    else
        qWarning() << "VideoJoiner: failed:" << t->error;
    emit finished(t->output, t->ok, t->error);
    t->deleteLater();
}

#include "framegrabber.h"
#include "fsoperations.h"
#include "private/qvideoframe_p.h"
#include <QDate>
#include <QImage>
#include <QMediaMetaData>
#include <QMediaPlayer>

FrameGrabber::FrameGrabber(QObject *parent)
    : QVideoProbe(parent), m_source(nullptr)
{
    connect(this, &QVideoProbe::videoFrameProbed, this, &FrameGrabber::emitVideoFrameProbed);
}

bool FrameGrabber::setSource(QObject* sourceObj)
{
    m_source = sourceObj;
    if (m_source != nullptr) {
        QMediaPlayer *player = qvariant_cast<QMediaPlayer *>(sourceObj->property("mediaObject"));
        return QVideoProbe::setSource(player);
    }
    return QVideoProbe::setSource((QMediaPlayer*)0);
}

void FrameGrabber::emitVideoFrameProbed(const QVideoFrame &frame)
{
    if (frame.isValid()) {
        int orientation = 0;
        QMediaPlayer *player = qvariant_cast<QMediaPlayer *>(m_source->property("mediaObject"));
        if (player && player->isMetaDataAvailable()) {
            QString str = player->metaData("image-orientation").toString();
            if (!str.isEmpty()) {
                str.remove(0, 7); // Remove "rotate-" and keep only angle value
                orientation = str.toInt();
            }
        }
        else
            qWarning() << "Unable to get media player!";

        QImage img(qt_imageFromVideoFrame(frame));
        FSOperations fs;
        QDateTime date = QDateTime::currentDateTime();
        QString path = fs.writableLocation("image", baseDir()) + "/PIC_" + date.toString("yyyyMMdd_hhmmss") + ".jpg";
        QImage imgRot;
        if (orientation != 0) {
            QTransform t;
            t.rotate(orientation);
            imgRot = img.transformed(t);
            if (imgRot.save(path))
                emit frameGrabbed(path);
            else
                qWarning() << "Unable to save" << path;
        } else {
            if (img.save(path))
                emit frameGrabbed(path);
            else
                qWarning() << "Unable to save" << path;
        }
        setSource((QObject*)0);
    }
}

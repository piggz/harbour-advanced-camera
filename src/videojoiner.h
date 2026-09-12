/*
  VideoJoiner — GPLv2 or later, like the rest of the project.

  Joins MP4 recordings made with identical settings into one file without
  re-encoding (qtdemux -> concat -> h264parse/aacparse -> mp4mux). Backs
  pause/resume: camerabin cannot pause an encoder, so every resume records
  a new segment. Runs in a worker thread.
*/
#ifndef VIDEOJOINER_H
#define VIDEOJOINER_H

#include <QObject>
#include <QString>
#include <QStringList>
#include <QThread>

class VideoJoiner : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool busy READ busy NOTIFY busyChanged)

public:
    explicit VideoJoiner(QObject *parent = nullptr);
    ~VideoJoiner() override;

    bool busy() const { return m_thread != nullptr; }

    // Emits finished() on the GUI thread; output must not be a segment.
    Q_INVOKABLE void join(const QStringList &segments, const QString &output);
    Q_INVOKABLE bool renameFile(const QString &from, const QString &to);

signals:
    void busyChanged();
    void finished(const QString &output, bool ok, const QString &error);

private slots:
    void onThreadFinished();

private:
    class JoinThread;
    JoinThread *m_thread = nullptr;
};

#endif // VIDEOJOINER_H

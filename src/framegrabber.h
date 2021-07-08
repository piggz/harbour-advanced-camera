#ifndef FRAMEGRABBER_H
#define FRAMEGRABBER_H

#include <QVideoProbe>

class FrameGrabber : public QVideoProbe
{
    Q_OBJECT
    Q_PROPERTY(QObject* source READ source WRITE setSource)
    Q_PROPERTY(bool active READ isActive)
    Q_PROPERTY(QString baseDir READ baseDir WRITE setBaseDir)
public:
    explicit FrameGrabber(QObject *parent = 0);
    QObject* source() { return m_source; }
    bool setSource(QObject *);
    QString baseDir() { return m_baseDir; }
    void setBaseDir(const QString &baseDir) { m_baseDir = baseDir; }
signals:
    void frameGrabbed(const QString &snapshotPath);
private slots:
    void emitVideoFrameProbed(const QVideoFrame &frame);
private:
    QObject *m_source;
    bool m_active;
    QString m_baseDir;
};

#endif // FRAMEGRABBER_H

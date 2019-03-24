#ifndef RESOLUTIONMODEL_H
#define RESOLUTIONMODEL_H

#include <QAbstractListModel>
#include <QCameraImageCapture>
#include <QMediaRecorder>
#include <QPair>

class ResolutionModel : public QAbstractListModel
{
    Q_OBJECT

public:

    enum ResolutionRoles {
        ResolutionName = Qt::UserRole + 1,
        ResolutionValue,
        ResolutionMpx
    };

    ResolutionModel();

    virtual QHash<int, QByteArray> roleNames() const;
    virtual int rowCount(const QModelIndex &parent) const;
    virtual QVariant data(const QModelIndex &index, int role) const;

    Q_INVOKABLE QSize sizeToRatio(const QSize &siz) const;
    Q_INVOKABLE void setImageCapture(QObject *camera);
    Q_INVOKABLE void setVideoRecorder(QObject *capture);
    Q_INVOKABLE void setMode(const QString &mode);
    Q_INVOKABLE QSize defaultResolution(const QString &mode);
    Q_INVOKABLE bool isValidResolution(const QSize &resolution, const QString &mode);

private:
    QMap<QString, QSize> m_resolutions;
    QList<QSize> m_supportedImageResolutions;
    QList<QSize> m_supportedVideoResolutions;
    QString m_mode = "image";
};

#endif // RESOLUTIONMODEL_H

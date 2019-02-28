#ifndef EXPOSUREMODEL_H
#define EXPOSUREMODEL_H

#include <QAbstractListModel>
#include <QCamera>
#include <QPair>

class ExposureModel : public QAbstractListModel
{
    Q_OBJECT

public:

    enum ExposureRoles {
        ExposureName = Qt::UserRole + 1,
        ExposureValue
    };

    ExposureModel();

    virtual QHash<int, QByteArray> roleNames() const;
    virtual int rowCount(const QModelIndex &parent) const;
    virtual QVariant data(const QModelIndex &index, int role) const;

    Q_INVOKABLE void setCamera(QObject *camera);
    Q_INVOKABLE QString iconName(QCameraExposure::ExposureMode e) const;

private:
    QMap<QCameraExposure::ExposureMode, QString> m_exposures;
    QCamera *m_camera = nullptr;

    QString exposureName(QCameraExposure::ExposureMode e) const;
};

#endif // EFFECTSMODEL_H

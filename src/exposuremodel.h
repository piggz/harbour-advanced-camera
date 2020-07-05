#ifndef EXPOSUREMODEL_H
#define EXPOSUREMODEL_H

#include <QAbstractListModel>
#include <QCamera>
#include <QPair>

class ExposureModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int rowCount READ rowCount NOTIFY rowCountChanged)

public:

    enum ExposureRoles {
        ExposureName = Qt::UserRole + 1,
        ExposureValue
    };

    ExposureModel();

    virtual QHash<int, QByteArray> roleNames() const;
    virtual int rowCount(const QModelIndex &parent = QModelIndex()) const;
    virtual QVariant data(const QModelIndex &index, int role) const;

    Q_INVOKABLE void setCamera(QObject *camera);
    Q_INVOKABLE QString iconName(QCameraExposure::ExposureMode e) const;

private:
    QMap<QCameraExposure::ExposureMode, QString> m_exposures;
    QCamera *m_camera = nullptr;

    QString exposureName(QCameraExposure::ExposureMode e) const;

signals:
    void rowCountChanged();
};

#endif // EFFECTSMODEL_H

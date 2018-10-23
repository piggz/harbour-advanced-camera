#ifndef RESOLUTIONMODEL_H
#define RESOLUTIONMODEL_H

#include <QAbstractListModel>
#include <QCameraImageCapture>
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

    Q_INVOKABLE void setImageCapture(QObject *camera);

private:
    QMap<QString, QSize> m_resolutions;
    QCameraImageCapture *m_capture = nullptr;
};

#endif // RESOLUTIONMODEL_H

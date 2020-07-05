#ifndef ISOMODEL_H
#define ISOMODEL_H

#include <QAbstractListModel>
#include <QCamera>
#include <QPair>

class IsoModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int rowCount READ rowCount NOTIFY rowCountChanged)

public:

    enum IsoRoles {
        IsoName = Qt::UserRole + 1,
        IsoValue
    };

    IsoModel();

    virtual QHash<int, QByteArray> roleNames() const;
    virtual int rowCount(const QModelIndex &parent = QModelIndex()) const;
    virtual QVariant data(const QModelIndex &index, int role) const;

    Q_INVOKABLE void setCamera(QObject *camera);

private:
    QMap<int, QString> m_isoModes;
    QCamera *m_camera = nullptr;

    QString isoName(int iso) const;

signals:
    void rowCountChanged();
};

#endif // EFFECTSMODEL_H

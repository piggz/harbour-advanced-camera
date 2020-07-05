#ifndef EFFECTSMODEL_H
#define EFFECTSMODEL_H

#include <QAbstractListModel>
#include <QCamera>
#include <QPair>

class EffectsModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int rowCount READ rowCount NOTIFY rowCountChanged)

public:

    enum EffectRoles {
        EffectName = Qt::UserRole + 1,
        EffectValue
    };

    EffectsModel();

    virtual QHash<int, QByteArray> roleNames() const;
    virtual int rowCount(const QModelIndex &parent = QModelIndex()) const;
    virtual QVariant data(const QModelIndex &index, int role) const;

    Q_INVOKABLE void setCamera(QObject *camera);

private:
    QMap<QCameraImageProcessing::ColorFilter, QString> m_effects;
    QCamera *m_camera = nullptr;

    QString effectName(QCameraImageProcessing::ColorFilter c) const;

signals:
    void rowCountChanged();
};

#endif // EFFECTSMODEL_H

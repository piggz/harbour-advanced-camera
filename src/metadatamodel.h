#ifndef METADATAMODEL_H
#define METADATAMODEL_H

#include <QAbstractListModel>
#include <QMediaMetaData>
#include <QMediaPlayer>
#include <QObject>

class MetadataModel : public QAbstractListModel
{
    Q_OBJECT
public:
    enum MetadataRoles {
        MetadataName = Qt::UserRole + 1,
        MetadataValue
    };
    MetadataModel();
    QHash<int, QByteArray> roleNames() const;
    int rowCount(const QModelIndex &parent) const;
    QVariant data(const QModelIndex &index, int role) const;
    Q_INVOKABLE void setPlayer(QObject *player);
public slots:
    void getMetadata(bool available);
private:
    QMap<QString, QVariant> m_data;
    QMediaPlayer *m_player;
};

#endif // METADATAMODEL_H

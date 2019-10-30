#include "metadatamodel.h"

MetadataModel::MetadataModel()
{
}

QHash<int, QByteArray> MetadataModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[MetadataName] = "name";
    roles[MetadataValue] = "value";
    return roles;
}

int MetadataModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent);
    return m_data.count();
}

QVariant MetadataModel::data(const QModelIndex &index, int role) const
{
    QVariant v;

    if (!index.isValid() || index.row() > rowCount(index) || index.row() < 0) {
        return v;
    }

    if (role == MetadataValue) {
        v = m_data.values().at(index.row());
    } else if (role == MetadataName) {
        v = m_data.keys().at(index.row());
    }

    return v;
}

void MetadataModel::setPlayer(QObject *player)
{
    QMediaPlayer* pl = qvariant_cast<QMediaPlayer *>(player->property("mediaObject"));
    if (m_player != pl)
        m_player = pl;
    connect(m_player, &QMediaPlayer::metaDataAvailableChanged, this, &MetadataModel::getMetadata);
}

void MetadataModel::getMetadata(bool available)
{
    Q_UNUSED(available);
    if (m_player->isMetaDataAvailable())
    {
        QStringList meta (m_player->availableMetaData());
        qDebug() << "Metadata available:" << meta;
        beginResetModel();
        for (const QString &mdName : meta)
            m_data[mdName] = m_player->metaData(mdName);
        endResetModel();
        if (m_data.count() == 0)
            qDebug() << "No metadata found!";
    }
    else {
        qDebug() << "No metadata available!";
    }
}

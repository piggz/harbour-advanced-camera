#include "storagemodel.h"
#include <QDebug>
#include <QDir>
#include <QStandardPaths>
#include <QStorageInfo>

Storage::Storage(const QString &name, const QString &path) :
    m_name(name), m_path(path)
{
    qDebug() << "Storage:" << name << path;
}

StorageModel::StorageModel()
{
    scan();
}

QHash<int, QByteArray> StorageModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[StorageName] = "name";
    roles[StoragePath] = "value";
    return roles;
}

int StorageModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent);
    return m_storage.size();
}

QVariant StorageModel::data(const QModelIndex &index, int role) const
{
    QVariant v;

    if (!index.isValid() || index.row() > rowCount(index) || index.row() < 0) {
        return v;
    }

    switch(role) {
    case StorageName:
        return m_storage[index.row()].name();
    case StoragePath:
        return m_storage[index.row()].path();
    default:
        return QVariant();
    }
}

void StorageModel::scan()
{
    qDebug() << "Scanning storage directories";
    QString homeDir = QStandardPaths::writableLocation(QStandardPaths::HomeLocation);

    beginResetModel();
    m_storage.clear();
    m_storage.append(Storage(tr("Internal storage"), homeDir));

    for (const QStorageInfo &storage : QStorageInfo::mountedVolumes()) {

        QString mountPoint = storage.rootPath();

        // Sailfish OS specific mount point base for SD cards!
        if (storage.isValid() &&
            storage.isReady() &&
            (mountPoint.startsWith("/media") ||
             mountPoint.startsWith("/run/media/") /* SFOS >= 2.2 */ )
            ) {

            qDebug() << "Found storage:" << mountPoint;
            m_storage << Storage(QDir(mountPoint).dirName(), mountPoint);
        }
    }

    endResetModel();
    emit rowCountChanged();
}

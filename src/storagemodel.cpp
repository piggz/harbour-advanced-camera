#include "storagemodel.h"
#include <QDebug>
#include <QDir>
#include <QStandardPaths>

Storage::Storage(const QString &name, const QString &path) :
    m_name(name), m_path(path)
{
    qDebug() << "Storage:" << name << path;
}

StorageModel::StorageModel()
{
    scan("/media/sdcard");
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

void StorageModel::scan(const QString &baseDir)
{
    qDebug() << "Scanning" << baseDir;
    QString homeDir = QStandardPaths::writableLocation(QStandardPaths::HomeLocation);
    QDir subRoot(baseDir);
    QStringList subDirs = subRoot.entryList(QDir::AllDirs|QDir::NoDotAndDotDot); // Add QDir::Writable ?
    beginResetModel();
    m_storage.clear();
    m_storage.append(Storage(tr("Internal storage"), homeDir));
    // TODO: add "Android" for /home/nemo/android_storage if it exists ?
    for (const QString &dir : subDirs) {
        m_storage.append(Storage(dir, baseDir + "/" + dir));
    }
    endResetModel();
}

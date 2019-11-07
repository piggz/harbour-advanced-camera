#ifndef STORAGEMODEL_H
#define STORAGEMODEL_H

#include <QAbstractListModel>
#include <QObject>

class Storage
{
public:
    explicit Storage(const QString &name, const QString &path);
    QString name() const { return m_name; }
    QString path() const { return m_path; }
private:
    QString m_name, m_path;
};

class StorageModel : public QAbstractListModel
{
    Q_OBJECT
public:
    enum StorageRoles
    {
        StorageName = Qt::UserRole + 1,
        StoragePath
    };

    StorageModel();
    virtual QHash<int, QByteArray> roleNames() const;
    virtual int rowCount(const QModelIndex &parent) const;
    virtual QVariant data(const QModelIndex &index, int role) const;
    Q_INVOKABLE QVariant getName(int index) const { return m_storage.at(index).name(); }
    Q_INVOKABLE QVariant getPath(int index) const { return m_storage.at(index).path(); }
public slots:
    void scan(const QString &baseDir);
private:
    QList<Storage> m_storage;
};

#endif // STORAGEMODEL_H

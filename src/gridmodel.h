#ifndef GRIDMODEL_H
#define GRIDMODEL_H

#include <QAbstractListModel>

struct GridMode
{
    QString name;
    QString id;
};

class GridModel : public QAbstractListModel
{
public:
    explicit GridModel(QObject* parent = nullptr);

    int rowCount(const QModelIndex &parent) const;
    QVariant data(const QModelIndex &index, int role) const;
    QHash<int, QByteArray> roleNames() const;
    
private:
    QList<GridMode> m_gridModes;
};

#endif // GRIDMODEL_H

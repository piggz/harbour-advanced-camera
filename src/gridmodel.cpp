#include "gridmodel.h"

GridModel::GridModel(QObject* parent) : QAbstractListModel(parent)
{
    m_gridModes = {{"none", tr("none")}, {"thirds", tr("thirds")}, {"ambiente", tr("ambiente")}};
}

int GridModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent);
    return m_gridModes.size();
}

QVariant GridModel::data(const QModelIndex &index, int role) const
{
    switch (role) {
    case Qt::UserRole:
        return QVariant(m_gridModes[index.row()].id);
    case Qt::UserRole + 1:
        return QVariant(m_gridModes[index.row()].name);
    }
    return QVariant();
}

QHash<int, QByteArray> GridModel::roleNames() const
{
    QHash<int, QByteArray> names;

    names[Qt::UserRole] = "value";
    names[Qt::UserRole + 1] = "name";

    return names;
}

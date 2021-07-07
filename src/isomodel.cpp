/**
harbour-advanced-camera C++ Camera Models
Copyright (C) 2019 Adam Pigg (adam@piggz.co.uk)

This library is free software; you can redistribute it and/or
modify it under the terms of the GNU Lesser General Public
License as published by the Free Software Foundation; either
version 2.1 of the License, or (at your option) any later version.

This library is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public
License along with this library; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
**/
#include "isomodel.h"

IsoModel::IsoModel()
{
}

QHash<int, QByteArray> IsoModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[IsoName] = "name";
    roles[IsoValue] = "value";
    return roles;
}

int IsoModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent);
    return m_isoModes.size();
}

QVariant IsoModel::data(const QModelIndex &index, int role) const
{
    QVariant v;

    if (!index.isValid() || index.row() > rowCount(index) || index.row() < 0) {
        return v;
    }

    if (role == IsoName) {
        v = m_isoModes.at(index.row()).second;
    } else if (role == IsoValue) {
        v = m_isoModes.at(index.row()).first;
    }

    return v;
}

void IsoModel::setCamera(QObject *camera)
{
    QCamera *cam = camera->property("mediaObject").value<QCamera *>();
    if (m_camera != cam) {
        m_camera = cam;

        beginResetModel();

        QList<int> supportedIsoRange = m_camera->exposure()->supportedIsoSensitivities();

        for (int i = 0; i < supportedIsoRange.count() ; i++) {
            m_isoModes.push_back(std::make_pair(i, isoName(supportedIsoRange[i])));
            qDebug() << "Found support for" << isoName(supportedIsoRange[i]);
        }
        endResetModel();
        emit rowCountChanged();

        if (m_isoModes.size() == 0) {
            qDebug() << "No ISO modes found";
        }
    }
}

QString IsoModel::isoName(int iso) const
{
    QString name;

    if (iso == 0) {
        name = tr("Auto ISO");
    } else if (iso == 1) {
        name = "ISO_HJR";
    } else {
        name = QString("ISO_%1").arg(iso);
    }
    return name;
}

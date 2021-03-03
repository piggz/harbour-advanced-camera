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
#include "wbmodel.h"

WbModel::WbModel()
{
}

QHash<int, QByteArray> WbModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[WbName] = "name";
    roles[WbValue] = "value";
    return roles;
}

int WbModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent);
    return m_wbModes.count();
}

QVariant WbModel::data(const QModelIndex &index, int role) const
{
    QVariant v;

    if (!index.isValid() || index.row() > rowCount(index) || index.row() < 0) {
        return v;
    }

    if (role == WbName) {
        v = m_wbModes.values().at(index.row());
    } else if (role == WbValue) {
        v = m_wbModes.keys().at(index.row());
    }

    return v;
}

void WbModel::setCamera(QObject *camera)
{
    QCamera *cam = camera->property("mediaObject").value<QCamera *>();
    if (m_camera != cam) {
        m_camera = cam;

        beginResetModel();
        for (int c = (int)QCameraImageProcessing::WhiteBalanceAuto;
                c <= (int)QCameraImageProcessing::WhiteBalanceWarmFluorescent; c++) {
            if (m_camera->imageProcessing()->isWhiteBalanceModeSupported((QCameraImageProcessing::WhiteBalanceMode)c)) {
                qDebug() << "Found support for" << (QCameraImageProcessing::WhiteBalanceMode)c;
                m_wbModes[(QCameraImageProcessing::WhiteBalanceMode)c] = wbName((QCameraImageProcessing::WhiteBalanceMode)c);
            }
        }
        endResetModel();
        emit rowCountChanged();

        if (m_wbModes.size() == 0) {
            qDebug() << "No white balance modes found";
        }
    }
}

QString WbModel::wbName(QCameraImageProcessing::WhiteBalanceMode wb) const
{
    QString name;

    switch (wb) {
    case QCameraImageProcessing::WhiteBalanceAuto:
        name = tr("Auto");
        break;
    case QCameraImageProcessing::WhiteBalanceManual:
        name = tr("Manual");
        break;
    case QCameraImageProcessing::WhiteBalanceSunlight:
        name = tr("Sunlight");
        break;
    case QCameraImageProcessing::WhiteBalanceCloudy:
        name = tr("Cloudy");
        break;
    case QCameraImageProcessing::WhiteBalanceShade:
        name = tr("Shade");
        break;
    case QCameraImageProcessing::WhiteBalanceTungsten:
        name = tr("Tungsten");
        break;
    case QCameraImageProcessing::WhiteBalanceFluorescent:
        name = tr("Fluorescent");
        break;
    case QCameraImageProcessing::WhiteBalanceFlash:
        name = tr("Flash");
        break;
    case QCameraImageProcessing::WhiteBalanceSunset:
        name = tr("Sunset");
        break;
    case QCameraImageProcessing::WhiteBalanceWarmFluorescent:
        name = tr("Warm Fluorescent");
        break;
    default:
        name = tr("Unknown");
        break;
    }
    return name;
}

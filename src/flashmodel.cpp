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
#include "flashmodel.h"

FlashModel::FlashModel()
{
}

QHash<int, QByteArray> FlashModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[FlashName] = "name";
    roles[FlashValue] = "value";
    return roles;
}

int FlashModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent);
    return m_flashModes.size();
}

QVariant FlashModel::data(const QModelIndex &index, int role) const
{
    QVariant v;

    if (!index.isValid() || index.row() > rowCount(index) || index.row() < 0) {
        return v;
    }

    if (role == FlashName) {
        v = m_flashModes.at(index.row()).second;
    } else if (role == FlashValue) {
        v = m_flashModes.at(index.row()).first;
    }

    return v;
}

void FlashModel::setCamera(QObject *camera)
{
    // even when m_camera instance is the same, deviceId could have changed and so available focus modes
    m_camera = camera->property("mediaObject").value<QCamera *>();

    beginResetModel();
    m_flashModes.clear();
    for (int c = (int)QCameraExposure::FlashAuto; c <= (int)QCameraExposure::FlashManual; c++) {
        if (m_camera->exposure()->isFlashModeSupported((QCameraExposure::FlashMode)c)
                && flashName((QCameraExposure::FlashMode)c) != tr("Unknown")) {
            qDebug() << "Found support for" << (QCameraExposure::FlashMode)c;
            m_flashModes.push_back(std::make_pair((QCameraExposure::FlashMode)c, flashName((QCameraExposure::FlashMode)c)));
        }
    }
    endResetModel();
    emit rowCountChanged();

    if (m_flashModes.size() == 0) {
        qDebug() << "No flash modes found";
    }
}

QString FlashModel::flashName(QCameraExposure::FlashMode flash) const
{
    QString name;

    switch (flash) {
    case QCameraExposure::FlashAuto:
        name = tr("Auto");
        break;
    case QCameraExposure::FlashOff:
        name = tr("Off");
        break;
    case QCameraExposure::FlashOn:
        name = tr("On");
        break;
    case QCameraExposure::FlashRedEyeReduction:
        name = tr("Red Eye Reduction");
        break;
    case QCameraExposure::FlashFill:
        name = tr("Fill");
        break;
    case QCameraExposure::FlashTorch:
        name = tr("Torch");
        break;
    case QCameraExposure::FlashVideoLight:
        name = tr("Video Light");
        break;
    case QCameraExposure::FlashSlowSyncFrontCurtain:
        name = tr("Slow Sync Front Curtain");
        break;
    case QCameraExposure::FlashSlowSyncRearCurtain:
        name = tr("Slow Sync Rear Curtain");
        break;
    case QCameraExposure::FlashManual:
        name = tr("Manual");
        break;
    default:
        name = tr("Unknown");
        break;
    }

    return name;
}

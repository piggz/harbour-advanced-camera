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
#include "effectsmodel.h"

EffectsModel::EffectsModel()
{
}

QHash<int, QByteArray> EffectsModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[EffectName] = "name";
    roles[EffectValue] = "value";
    return roles;
}

int EffectsModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent);
    return m_effects.size();
}

QVariant EffectsModel::data(const QModelIndex &index, int role) const
{
    QVariant v;

    if (!index.isValid() || index.row() > rowCount(index) || index.row() < 0) {
        return v;
    }

    if (role == EffectName) {
        v = m_effects[index.row()].second;
    } else if (role == EffectValue) {
        v = m_effects.at(index.row()).first;
    }

    return v;
}

void EffectsModel::setCamera(QObject *camera)
{
    // even when m_camera instance is the same, deviceId could have changed and so available focus modes
    m_camera = camera->property("mediaObject").value<QCamera *>();

    beginResetModel();
    m_effects.clear();
    for (int c = (int)QCameraImageProcessing::ColorFilterNone;
            c <= (int)QCameraImageProcessing::ColorFilterNeon; c++) {
        if (m_camera->imageProcessing()->isColorFilterSupported((QCameraImageProcessing::ColorFilter)c)) {
            qDebug() << "Found support for" << (QCameraImageProcessing::ColorFilter)c;
            m_effects.push_back(std::make_pair((QCameraImageProcessing::ColorFilter)c, effectName((QCameraImageProcessing::ColorFilter)c)));
        }
    }
    endResetModel();
    emit rowCountChanged();

    if (m_effects.size() == 0) {
        qDebug() << "No effect modes found";
    }
}

QString EffectsModel::effectName(QCameraImageProcessing::ColorFilter c) const
{
    QString name;

    switch (c) {
    case QCameraImageProcessing::ColorFilterNone:
        name = tr("None");
        break;
    case QCameraImageProcessing::ColorFilterAqua:
        name = tr("Aqua");
        break;
    case QCameraImageProcessing::ColorFilterBlackboard:
        name = tr("Blackboard");
        break;
    case QCameraImageProcessing::ColorFilterGrayscale:
        name = tr("Grayscale");
        break;
    case QCameraImageProcessing::ColorFilterNegative:
        name = tr("Negative");
        break;
    case QCameraImageProcessing::ColorFilterPosterize:
        name = tr("Posterize");
        break;
    case QCameraImageProcessing::ColorFilterSepia:
        name = tr("Sepia");
        break;
    case QCameraImageProcessing::ColorFilterSolarize:
        name = tr("Solarize");
        break;
    case QCameraImageProcessing::ColorFilterWhiteboard:
        name = tr("Whiteboard");
        break;
    case QCameraImageProcessing::ColorFilterEmboss:
        name = tr("Emboss");
        break;
    case QCameraImageProcessing::ColorFilterSketch:
        name = tr("Sketch");
        break;
    case QCameraImageProcessing::ColorFilterNeon:
        name = tr("Neon");
        break;
    default:
        name = "Unknown";
        break;
    }

    return name;
}

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
#include "exposuremodel.h"

ExposureModel::ExposureModel()
{
}

QHash<int, QByteArray> ExposureModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[ExposureName] = "name";
    roles[ExposureValue] = "value";
    return roles;
}

int ExposureModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent);
    return m_exposures.size();
}

QVariant ExposureModel::data(const QModelIndex &index, int role) const
{
    QVariant v;

    if (!index.isValid() || index.row() > rowCount(index) || index.row() < 0) {
        return v;
    }

    if (role == ExposureName) {
        v = m_exposures.at(index.row()).second;
    } else if (role == ExposureValue) {
        v = m_exposures.at(index.row()).first;
    }

    return v;
}

void ExposureModel::setCamera(QObject *camera)
{
    // even when m_camera instance is the same, deviceId could have changed and so available focus modes
    m_camera = camera->property("mediaObject").value<QCamera *>();

    beginResetModel();
    m_exposures.clear();
    for (int c = (int)QCameraExposure::ExposureAuto; c <= (int)QCameraExposure::ExposureHDR; c++) {
        if (m_camera->exposure()->isExposureModeSupported((QCameraExposure::ExposureMode)c)) {
            qDebug() << "Found support for" << (QCameraExposure::ExposureMode)c;
            m_exposures.push_back(std::make_pair((QCameraExposure::ExposureMode)c, exposureName((QCameraExposure::ExposureMode)c)));
        }
    }
    endResetModel();
    emit rowCountChanged();

    if (m_exposures.size() == 0) {
        qDebug() << "No exposure modes found";
    }
}

QString ExposureModel::exposureName(QCameraExposure::ExposureMode e) const
{
    QString name;

    switch (e) {
    case QCameraExposure::ExposureAuto:
        name = tr("Automatic Scene Detection");
        break;
    case QCameraExposure::ExposureAction:
        name = tr("Action");
        break;
    case QCameraExposure::ExposureManual:
        name = tr("Off");
        break;
    case QCameraExposure::ExposureAR:
        name = tr("Augmented Reality");
        break;
    case QCameraExposure::ExposureBacklight:
        name = tr("Backlight");
        break;
    case QCameraExposure::ExposureBarcode:
        name = tr("Barcode");
        break;
    case QCameraExposure::ExposureBeach:
        name = tr("Beach");
        break;
    case QCameraExposure::ExposureCandlelight:
        name = tr("Candlelight");
        break;
    case QCameraExposure::ExposureFireworks:
        name = tr("Fireworks");
        break;
    case QCameraExposure::ExposureFlowers:
        name = tr("Flowers");
        break;
    case QCameraExposure::ExposureHDR:
        name = tr("HDR");
        break;
    case QCameraExposure::ExposureLandscape:
        name = tr("Landscape");
        break;
    case QCameraExposure::ExposureLargeAperture:
        name = tr("Large Aperture");
        break;
    case QCameraExposure::ExposureNight:
        name = tr("Night");
        break;
    case QCameraExposure::ExposureNightPortrait:
        name = tr("Night Portrait");
        break;
    case QCameraExposure::ExposureParty:
        name = tr("Party");
        break;
    case QCameraExposure::ExposurePortrait:
        name = tr("Portrait");
        break;
    case QCameraExposure::ExposureSmallAperture:
        name = tr("Small Aperture");
        break;
    case QCameraExposure::ExposureSnow:
        name = tr("Snow");
        break;
    case QCameraExposure::ExposureSports:
        name = tr("Sports");
        break;
    case QCameraExposure::ExposureSpotlight:
        name = tr("Spotlight");
        break;
    case QCameraExposure::ExposureSteadyPhoto:
        name = tr("Steady Photo");
        break;
    case QCameraExposure::ExposureSunset:
        name = tr("Sunset");
        break;
    case QCameraExposure::ExposureTheatre:
        name = tr("Theatre");
        break;

    default:
        name = "Unknown (" + QString::number(e) + ")";
    }

    return name;
}

QString ExposureModel::iconName(QCameraExposure::ExposureMode e) const
{
    QString name;

    switch (e) {
    case QCameraExposure::ExposureAuto:
        name = "asd";
        break;
    case QCameraExposure::ExposureAction:
        name = "action";
        break;
    case QCameraExposure::ExposureManual:
        name = "none";
        break;
    case QCameraExposure::ExposureAR:
        name = "ar";
        break;
    case QCameraExposure::ExposureBacklight:
        name = "backlight";
        break;
    case QCameraExposure::ExposureBarcode:
        name = "barcode";
        break;
    case QCameraExposure::ExposureBeach:
        name = "beach";
        break;
    case QCameraExposure::ExposureCandlelight:
        name = "candlelight";
        break;
    case QCameraExposure::ExposureFireworks:
        name = "fireworks";
        break;
    case QCameraExposure::ExposureFlowers:
        name = "flowers";
        break;
    case QCameraExposure::ExposureHDR:
        name = "hdr";
        break;
    case QCameraExposure::ExposureLandscape:
        name = "landscape";
        break;
    case QCameraExposure::ExposureLargeAperture:
        name = "large_aperture";
        break;
    case QCameraExposure::ExposureNight:
        name = "night";
        break;
    case QCameraExposure::ExposureNightPortrait:
        name = "night_portrait";
        break;
    case QCameraExposure::ExposureParty:
        name = "party";
        break;
    case QCameraExposure::ExposurePortrait:
        name = "portrait";
        break;
    case QCameraExposure::ExposureSmallAperture:
        name = "small_aperture";
        break;
    case QCameraExposure::ExposureSnow:
        name = "snow";
        break;
    case QCameraExposure::ExposureSports:
        name = "sports";
        break;
    case QCameraExposure::ExposureSpotlight:
        name = "spotlight";
        break;
    case QCameraExposure::ExposureSteadyPhoto:
        name = "steady_photo";
        break;
    case QCameraExposure::ExposureSunset:
        name = "sunset";
        break;
    case QCameraExposure::ExposureTheatre:
        name = "theatre";
        break;
    default:
        name = "unknown";
        break;
    }

    return name;
}

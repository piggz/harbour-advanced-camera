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
#include "resolutionmodel.h"

QSize ResolutionModel::sizeToRatio(const QSize &siz) const
{
    int a = siz.width();
    int b = siz.height();
    int c = a % b;
    int gcd = 0;

    while (c > 0) {
        a = b;
        b = c;
        c = a % b;
    }

    gcd = b;
    return siz / gcd;
}

ResolutionModel::ResolutionModel()
{
}

QHash<int, QByteArray> ResolutionModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[ResolutionName] = "name";
    roles[ResolutionValue] = "value";
    return roles;
}

int ResolutionModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent);
    return m_resolutions.size();
}

QVariant ResolutionModel::data(const QModelIndex &index, int role) const
{
    QVariant v;

    if (!index.isValid() || index.row() > rowCount(index) || index.row() < 0) {
        return v;
    }

    if (role == ResolutionName) {
        QSize r = sizeToRatio(m_resolutions.at(index.row()).second);
        v = QString("%1 (%2:%3)").arg(m_resolutions.at(index.row()).first).arg(r.width()).arg(r.height());
    } else if (role == ResolutionValue) {
        v = m_resolutions.at(index.row()).second;
    } else if (role == ResolutionMpx) {
        v = m_resolutions.at(index.row()).second.width() * m_resolutions.at(index.row()).second.height();
    }
    return v;
}

void ResolutionModel::setImageCapture(QObject *capture)
{
    QCameraImageCapture *cap = nullptr;
    QList<QCameraImageCapture *> captures = capture->findChildren<QCameraImageCapture *>();

    if (captures.count() > 0) {
        cap = captures[0]; //first will do!
    }

    if (cap) {
        m_supportedImageResolutions = cap->supportedResolutions();
        if (!m_mode.isEmpty()) {
            setMode(m_mode);
        }
    }
}

void ResolutionModel::setVideoRecorder(QObject *capture)
{
    QMediaRecorder *cap = nullptr;
    QList<QMediaRecorder *> captures = capture->findChildren<QMediaRecorder *>();

    if (captures.count() > 0) {
        cap = captures[0]; //first will do!
    }

    if (cap) {
        m_supportedVideoResolutions = cap->supportedResolutions();
        if (!m_mode.isEmpty()) {
            setMode(m_mode);
        }
    }
}

void ResolutionModel::setMode(const QString &mode)
{
    m_mode = mode;
    beginResetModel();
    m_resolutions.clear();

    if (mode == "image") {
        for (int i = 0; i < m_supportedImageResolutions.count() ; i++) {
            m_resolutions.push_back(std::make_pair(QString("%1x%2").arg(m_supportedImageResolutions[i].width()).arg(
                              m_supportedImageResolutions[i].height()), m_supportedImageResolutions[i]));
        }
    } else if (mode == "video") {
        for (int i = 0; i < m_supportedVideoResolutions.count() ; i++) {
            m_resolutions.push_back(std::make_pair(QString("%1x%2").arg(m_supportedVideoResolutions[i].width()).arg(
                              m_supportedVideoResolutions[i].height()), m_supportedVideoResolutions[i]));
        }
    }

    endResetModel();
    emit rowCountChanged();

    if (m_resolutions.size() > 0) {
         qDebug() << "Supported " << mode << " resolutions:";
        for(const auto &res: m_resolutions) {
            qDebug() << res.first;
        }
    } else {
        qWarning() << "No resolutions found";
    }
}

QSize ResolutionModel::defaultResolution(const QString &mode)
{
    if (mode == "video") {
        if (m_supportedVideoResolutions.count() > 0) {
            return m_supportedVideoResolutions.at(m_supportedVideoResolutions.count() - 1);
        }
    } else if (mode == "image") {
        if (m_supportedImageResolutions.count() > 0) {
            return m_supportedImageResolutions.at(m_supportedImageResolutions.count() - 1);
        }
    }
    return QSize(0, 0);
}

bool ResolutionModel::isValidResolution(const QSize &resolution, const QString &mode)
{
    if (mode == "image") {
        return m_supportedImageResolutions.contains(resolution);
    } else if (mode == "video") {
        return m_supportedVideoResolutions.contains(resolution);
    }
    return false;
}

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
#ifndef RESOLUTIONMODEL_H
#define RESOLUTIONMODEL_H

#include <QAbstractListModel>
#include <QCameraImageCapture>
#include <QMediaRecorder>
#include <QPair>

class ResolutionModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int rowCount READ rowCount NOTIFY rowCountChanged)

public:

    enum ResolutionRoles {
        ResolutionName = Qt::UserRole + 1,
        ResolutionValue,
        ResolutionMpx
    };

    ResolutionModel();

    virtual QHash<int, QByteArray> roleNames() const;
    virtual int rowCount(const QModelIndex &parent = QModelIndex()) const;
    virtual QVariant data(const QModelIndex &index, int role) const;

    Q_INVOKABLE QSize sizeToRatio(const QSize &siz) const;
    Q_INVOKABLE void setImageCapture(QObject *camera);
    Q_INVOKABLE void setVideoRecorder(QObject *capture);
    Q_INVOKABLE void setMode(const QString &mode);
    Q_INVOKABLE QSize defaultResolution(const QString &mode);
    Q_INVOKABLE bool isValidResolution(const QSize &resolution, const QString &mode);

private:
    QMap<QString, QSize> m_resolutions;
    QList<QSize> m_supportedImageResolutions;
    QList<QSize> m_supportedVideoResolutions;
    QString m_mode = "image";

signals:
    void rowCountChanged();
};

#endif // RESOLUTIONMODEL_H

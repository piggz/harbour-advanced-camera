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
#ifndef EXPOSUREMODEL_H
#define EXPOSUREMODEL_H

#include <QAbstractListModel>
#include <QCamera>
#include <QPair>

class ExposureModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int rowCount READ rowCount NOTIFY rowCountChanged)

public:

    enum ExposureRoles {
        ExposureName = Qt::UserRole + 1,
        ExposureValue
    };

    ExposureModel();

    virtual QHash<int, QByteArray> roleNames() const;
    virtual int rowCount(const QModelIndex &parent = QModelIndex()) const;
    virtual QVariant data(const QModelIndex &index, int role) const;

    Q_INVOKABLE void setCamera(QObject *camera);
    Q_INVOKABLE QString iconName(QCameraExposure::ExposureMode e) const;

private:
    QMap<QCameraExposure::ExposureMode, QString> m_exposures;
    QCamera *m_camera = nullptr;

    QString exposureName(QCameraExposure::ExposureMode e) const;

signals:
    void rowCountChanged();
};

#endif // EFFECTSMODEL_H

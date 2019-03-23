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
    return m_isoModes.count();
}

QVariant IsoModel::data(const QModelIndex &index, int role) const
{
    QVariant v;

    if (!index.isValid() || index.row() > rowCount(index) || index.row() < 0) {
        return v;
    }

    if (role == IsoName) {
        v = m_isoModes.values().at(index.row());
    } else if (role == IsoValue) {
        v = m_isoModes.keys().at(index.row());
    }

    return v;
}

void IsoModel::setCamera(QObject *camera)
{
    QCamera *cam = camera->property("mediaObject").value<QCamera*>();
    if (m_camera != cam) {
        m_camera = cam;

        beginResetModel();

        QList<int> supportedIsoRange = m_camera->exposure()->supportedIsoSensitivities();

        for (int i = 0; i < supportedIsoRange.count() ;i++) {
            m_isoModes[supportedIsoRange[i]] = isoName(supportedIsoRange[i]);
        }
        endResetModel();
    }

    qDebug() << m_isoModes;
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

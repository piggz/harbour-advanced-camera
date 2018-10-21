#include "resolutionmodel.h"

ResolutionModel::ResolutionModel()
{

}

QHash<int, QByteArray> ResolutionModel::roleNames() const {
    QHash<int, QByteArray> roles;
    roles[ResolutionName] = "name";
    roles[ResolutionValue] = "value";
    return roles;
}


int ResolutionModel::rowCount(const QModelIndex &parent) const
{
    return m_resolutions.count();
}

QVariant ResolutionModel::data(const QModelIndex &index, int role) const
{
    QVariant v;

    if (!index.isValid() || index.row() > rowCount(index) || index.row() < 0) {
        return v;
    }

    if (role == ResolutionName) {
        v = m_resolutions.keys().at(index.row());
    } else if (role == ResolutionValue) {
        v = m_resolutions.values().at(index.row());
    }
    return v;
}

void ResolutionModel::setImageCapture(QObject *capture)
{
    QCameraImageCapture *cap = nullptr;
    QList<QCameraImageCapture*> captures = capture->findChildren<QCameraImageCapture*>();

    if (captures.count() > 0) {
        cap = captures[0]; //fist will do!
    }

    if (m_capture != cap) {
        m_capture = cap;

        beginResetModel();

        QList<QSize> supportedResolutions = m_capture->supportedResolutions();

        for (int i = 0; i < supportedResolutions.count() ;i++) {
            m_resolutions[QString("%1x%2").arg(supportedResolutions[i].width()).arg(supportedResolutions[i].height())] = supportedResolutions[i];
        }
        endResetModel();
        qDebug() << supportedResolutions << m_resolutions;

    }

}

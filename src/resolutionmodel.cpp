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
    return m_resolutions.count();
}

QVariant ResolutionModel::data(const QModelIndex &index, int role) const
{
    QVariant v;

    if (!index.isValid() || index.row() > rowCount(index) || index.row() < 0) {
        return v;
    }

    if (role == ResolutionName) {
        QSize r = sizeToRatio(m_resolutions.values().at(index.row()));
        v = m_resolutions.keys().at(index.row()) + QString(" (%1:%2)").arg(r.width()).arg(r.height());
    } else if (role == ResolutionValue) {
        v = m_resolutions.values().at(index.row());
    } else if (role == ResolutionMpx) {
        v = m_resolutions.values().at(index.row()).width() * m_resolutions.values().at(index.row()).height();
    }
    return v;
}

void ResolutionModel::setImageCapture(QObject *capture)
{
    QCameraImageCapture *cap = nullptr;
    QList<QCameraImageCapture*> captures = capture->findChildren<QCameraImageCapture*>();

    if (captures.count() > 0) {
        cap = captures[0]; //first will do!
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

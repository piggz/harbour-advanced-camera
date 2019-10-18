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

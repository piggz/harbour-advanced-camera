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
    QCamera *cam = camera->property("mediaObject").value<QCamera*>();
    if (m_camera != cam) {
        m_camera = cam;

        beginResetModel();
        for (int c = (int)QCameraImageProcessing::WhiteBalanceAuto; c <= (int)QCameraImageProcessing::WhiteBalanceWarmFluorescent;c++) {
            qDebug() << "Checking supported:" << (QCameraImageProcessing::WhiteBalanceMode)c;

            if (m_camera->imageProcessing()->isWhiteBalanceModeSupported((QCameraImageProcessing::WhiteBalanceMode)c)){
                m_wbModes[(QCameraImageProcessing::WhiteBalanceMode)c] = wbName((QCameraImageProcessing::WhiteBalanceMode)c);
            }
        }
        endResetModel();
    }

    qDebug() << m_wbModes;
}

QString WbModel::wbName(QCameraImageProcessing::WhiteBalanceMode wb) const
{
    QString name;

    if (wb == QCameraImageProcessing::WhiteBalanceAuto) {
        name = tr("Auto");
    } else if (wb == QCameraImageProcessing::WhiteBalanceManual) {
        name = tr("Manual");
    } else if (wb == QCameraImageProcessing::WhiteBalanceSunlight) {
        name = tr("Sunlight");
    } else if (wb == QCameraImageProcessing::WhiteBalanceCloudy) {
        name = tr("Cloudy");
    } else if (wb == QCameraImageProcessing::WhiteBalanceShade) {
        name = tr("Shade");
    } else if (wb == QCameraImageProcessing::WhiteBalanceTungsten) {
        name = tr("Tungsten");
    } else if (wb == QCameraImageProcessing::WhiteBalanceFluorescent) {
        name = tr("Fluorescent");
    } else if (wb == QCameraImageProcessing::WhiteBalanceFlash) {
        name = tr("Flash");
    } else if (wb == QCameraImageProcessing::WhiteBalanceSunset) {
        name = tr("Sunset");
    } else if (wb == QCameraImageProcessing::WhiteBalanceWarmFluorescent) {
        name = tr("Warm Fluorescent");
    } else{
        name = tr("Unknown");
    }
    return name;
}

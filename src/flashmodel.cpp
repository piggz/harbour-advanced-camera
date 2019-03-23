#include "flashmodel.h"

FlashModel::FlashModel()
{
}

QHash<int, QByteArray> FlashModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[FlashName] = "name";
    roles[FlashValue] = "value";
    return roles;
}

int FlashModel::rowCount(const QModelIndex &parent) const
{
    return m_flashModes.count();
}

QVariant FlashModel::data(const QModelIndex &index, int role) const
{
    QVariant v;

    if (!index.isValid() || index.row() > rowCount(index) || index.row() < 0) {
        return v;
    }

    if (role == FlashName) {
        v = m_flashModes.values().at(index.row());
    } else if (role == FlashValue) {
        v = m_flashModes.keys().at(index.row());
    }

    return v;
}

void FlashModel::setCamera(QObject *camera)
{
    QCamera *cam = camera->property("mediaObject").value<QCamera*>();
    if (m_camera != cam) {
        m_camera = cam;

        beginResetModel();
        for (int c = (int)QCameraExposure::FlashAuto; c <= (int)QCameraExposure::FlashManual;c++) {
            qDebug() << "Checking supported:" << (QCameraExposure::FlashMode)c;

            if (m_camera->exposure()->isFlashModeSupported((QCameraExposure::FlashMode)c) && flashName((QCameraExposure::FlashMode)c) != tr("Unknown")){
                m_flashModes[(QCameraExposure::FlashMode)c] = flashName((QCameraExposure::FlashMode)c);
            }
        }
        endResetModel();
    }
}

QString FlashModel::flashName(QCameraExposure::FlashMode focus) const
{
    QString name;

    if (focus == QCameraExposure::FlashAuto) {
        name = tr("Auto");
    } else if (focus == QCameraExposure::FlashOff) {
        name = tr("Off");
    } else if (focus == QCameraExposure::FlashOn) {
        name = tr("On");
    } else if (focus == QCameraExposure::FlashRedEyeReduction) {
        name = tr("Red Eye Reduction");
    } else if (focus == QCameraExposure::FlashFill) {
        name = tr("Fill");
    } else if (focus == QCameraExposure::FlashTorch) {
        name = tr("Torch");
    } else if (focus == QCameraExposure::FlashVideoLight) {
        name = tr("Video Light");
    } else if (focus == QCameraExposure::FlashSlowSyncFrontCurtain) {
        name = tr("Slow Sync Front Curtain");
    } else if (focus == QCameraExposure::FlashSlowSyncRearCurtain) {
        name = tr("Slow Sync Rear Curtain");
    } else if (focus == QCameraExposure::FlashManual) {
        name = tr("Manual");
    } else{
        name = tr("Unknown");
    }

    return name;
}

#include "exposuremodel.h"

ExposureModel::ExposureModel()
{

}

QHash<int, QByteArray> ExposureModel::roleNames() const {
    QHash<int, QByteArray> roles;
    roles[ExposureName] = "name";
    roles[ExposureValue] = "value";
    return roles;
}


int ExposureModel::rowCount(const QModelIndex &parent) const
{
    return m_exposures.count();
}

QVariant ExposureModel::data(const QModelIndex &index, int role) const
{
    QVariant v;

    if (!index.isValid() || index.row() > rowCount(index) || index.row() < 0) {
        return v;
    }

    if (role == ExposureName) {
        v = m_exposures.values().at(index.row());
    } else if (role == ExposureValue) {
        v = m_exposures.keys().at(index.row());
    }

    return v;
}

void ExposureModel::setCamera(QObject *camera)
{
    QCamera *cam = camera->property("mediaObject").value<QCamera*>();
    if (m_camera != cam) {
        m_camera = cam;

        beginResetModel();
        for (int c = (int)QCameraExposure::ExposureAuto; c <= (int)QCameraExposure::ExposureHDR;c++) {
            qDebug() << "Checking supported:" << (QCameraExposure::ExposureMode)c;

            if (m_camera->exposure()->isExposureModeSupported((QCameraExposure::ExposureMode)c)){
                m_exposures[(QCameraExposure::ExposureMode)c] = exposureName((QCameraExposure::ExposureMode)c);
            }
        }
        endResetModel();
    }

    qDebug() << m_exposures;
}

QString ExposureModel::exposureName(QCameraExposure::ExposureMode e) const
{
    QString name;

    switch(e) {
    case QCameraImageProcessing::ColorFilterNone:
        name = tr("None");
        break;
    case QCameraImageProcessing::ColorFilterAqua:
        name = tr("Aqua");
        break;
    case QCameraImageProcessing::ColorFilterBlackboard:
        name = tr("Blackboard");
        break;
    case QCameraImageProcessing::ColorFilterGrayscale:
        name = tr("Grayscale");
        break;
    case QCameraImageProcessing::ColorFilterNegative:
        name = tr("Negative");
        break;
    case QCameraImageProcessing::ColorFilterPosterize:
        name = tr("Posterize");
        break;
    case QCameraImageProcessing::ColorFilterSepia:
        name = tr("Sepia");
        break;
    case QCameraImageProcessing::ColorFilterSolarize:
        name = tr("Solarize");
        break;
    case QCameraImageProcessing::ColorFilterWhiteboard:
        name = tr("Whiteboard");
        break;
    case QCameraImageProcessing::ColorFilterEmboss:
        name = tr("Emboss");
        break;
    case QCameraImageProcessing::ColorFilterSketch:
        name = tr("Sketch");
        break;
    case QCameraImageProcessing::ColorFilterNeon:
        name = tr("Neon");
        break;

    default:
        name = "Unknown";
    }

    return name;
}

#include "effectsmodel.h"

EffectsModel::EffectsModel()
{
}

QHash<int, QByteArray> EffectsModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[EffectName] = "name";
    roles[EffectValue] = "value";
    return roles;
}

int EffectsModel::rowCount(const QModelIndex &parent) const
{
    return m_effects.count();

}

QVariant EffectsModel::data(const QModelIndex &index, int role) const
{
    QVariant v;

    if (!index.isValid() || index.row() > rowCount(index) || index.row() < 0) {
        return v;
    }

    if (role == EffectName) {
        v = m_effects.values().at(index.row());
    } else if (role == EffectValue) {
        v = m_effects.keys().at(index.row());
    }

    return v;
}

void EffectsModel::setCamera(QObject *camera)
{
    QCamera *cam = camera->property("mediaObject").value<QCamera*>();
    if (m_camera != cam) {
        m_camera = cam;

        beginResetModel();
        for (int c = (int)QCameraImageProcessing::ColorFilterNone; c <= (int)QCameraImageProcessing::ColorFilterNeon;c++) {
            qDebug() << "Checking supported:" << (QCameraImageProcessing::ColorFilter)c;

            if (m_camera->imageProcessing()->isColorFilterSupported((QCameraImageProcessing::ColorFilter)c)){
                m_effects[(QCameraImageProcessing::ColorFilter)c] = effectName((QCameraImageProcessing::ColorFilter)c);
            }
        }
        endResetModel();
    }
    qDebug() << m_effects;
}

QString EffectsModel::effectName(QCameraImageProcessing::ColorFilter c) const
{
    QString name;

    switch(c) {
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

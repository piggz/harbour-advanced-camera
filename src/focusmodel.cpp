#include "focusmodel.h"

FocusModel::FocusModel()
{
}

QHash<int, QByteArray> FocusModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[FocusName] = "name";
    roles[FocusValue] = "value";
    return roles;
}

int FocusModel::rowCount(const QModelIndex &parent) const
{
    return m_focusModes.count();
}

QVariant FocusModel::data(const QModelIndex &index, int role) const
{
    QVariant v;

    if (!index.isValid() || index.row() > rowCount(index) || index.row() < 0) {
        return v;
    }

    if (role == FocusName) {
        v = m_focusModes.values().at(index.row());
    } else if (role == FocusValue) {
        v = m_focusModes.keys().at(index.row());
    }

    return v;
}

void FocusModel::setCamera(QObject *camera)
{
    QCamera *cam = camera->property("mediaObject").value<QCamera*>();
    if (m_camera != cam) {
        m_camera = cam;

        beginResetModel();
        for (int c = (int)QCameraFocus::ManualFocus; c <= (int)QCameraFocus::MacroFocus;c++) {
            qDebug() << "Checking supported:" << (QCameraFocus::FocusMode)c;

            if (m_camera->focus()->isFocusModeSupported((QCameraFocus::FocusMode)c) && focusName((QCameraFocus::FocusMode)c) != tr("Unknown")){
                m_focusModes[(QCameraFocus::FocusMode)c] = focusName((QCameraFocus::FocusMode)c);
            }
        }
        endResetModel();
    }
}

QString FocusModel::focusName(QCameraFocus::FocusMode focus) const
{
    QString name;

    if (focus == QCameraFocus::ManualFocus) {
        name = tr("Manual");
    } else if (focus == QCameraFocus::HyperfocalFocus) {
        name = tr("Hyperfocal");
    } else if (focus == QCameraFocus::InfinityFocus) {
        name = tr("Infinity");
    } else if (focus == QCameraFocus::AutoFocus) {
        name = tr("Auto");
    } else if (focus == QCameraFocus::ContinuousFocus) {
        name = tr("Continuous");
    } else if (focus == QCameraFocus::MacroFocus) {
        name = tr("Macro");
    } else{
        name = tr("Unknown");
    }
    return name;
}

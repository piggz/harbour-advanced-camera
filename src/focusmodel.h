#ifndef FOCUSMODEL_H
#define FOCUSMODEL_H

#include <QAbstractListModel>
#include <QCamera>
#include <QPair>

class FocusModel : public QAbstractListModel
{
    Q_OBJECT

public:

    enum FocusRoles {
        FocusName = Qt::UserRole + 1,
        FocusValue
    };

    FocusModel();

    virtual QHash<int, QByteArray> roleNames() const;
    virtual int rowCount(const QModelIndex &parent) const;
    virtual QVariant data(const QModelIndex &index, int role) const;

    Q_INVOKABLE void setCamera(QObject *camera);

private:
    QMap<int, QString> m_focusModes;
    QCamera *m_camera = nullptr;

    QString focusName(QCameraFocus::FocusMode focus) const;
};

#endif // FOCUSMODEL_H

#include "fsoperations.h"
#include <QAbstractListModel>
#include <QDebug>
#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QStandardPaths>

FSOperations::FSOperations(QObject *parent) : QObject(parent)
{
}

bool FSOperations::deleteFile(const QString &path)
{
    QFile f(path);
    return f.remove();
}

QString FSOperations::writableLocation(const QString &type, const QString &baseDir)
{
    QString dir;
    if (type == "image") {
        dir = baseDir + "/Pictures/AdvancedCam";
    } else if (type == "video") {
        dir = baseDir + "/Videos/AdvancedCam";
    } else {
        return QString();
    }

    if (!createFolder(dir)) {
        qWarning() << "Unable to create" << dir << ", fallback to home dir!";
        emit rescan("/media/sdcard");
        return writableLocation(type, QStandardPaths::writableLocation(QStandardPaths::HomeLocation));
    }
    return dir;
}

bool FSOperations::createFolder(const QString &path)
{
    QDir dir(path);
    if (!dir.exists()) {
        return dir.mkpath(".");
    }
    return true;
}

qint64 FSOperations::getFileSize(const QString &path)
{
    QFileInfo info(path);
    if (info.exists())
        return info.size();
    return 0;
}

QString FSOperations::getFileSizeHuman(const QString &path)
{
    float num = (float)getFileSize(path);
    QStringList list;
    list << "KiB" << "MiB" << "GiB" << "TiB";

    QStringListIterator i(list);
    QString unit("B");

    if (num < 1024.0)
        return QString().setNum(num, 'f', 0) + " " + unit;

    while(num >= 1024.0 && i.hasNext())
     {
        unit = i.next();
        num /= 1024.0;
    }
    return QString().setNum(num, 'f', 2) + " " + unit;
}

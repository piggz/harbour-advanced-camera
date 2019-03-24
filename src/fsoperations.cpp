#include "fsoperations.h"
#include <QFile>
#include <QDir>
#include <QStandardPaths>

FSOperations::FSOperations(QObject *parent) : QObject(parent)
{
}

bool FSOperations::deleteFile(const QString &path)
{
    QFile f(path);
    return f.remove();
}

QString FSOperations::writableLocation(const QString &type)
{
    if (type == "image") {
        return QStandardPaths::writableLocation(QStandardPaths::PicturesLocation);
    } else if (type == "video") {
        return QStandardPaths::writableLocation(QStandardPaths::MoviesLocation);
    }
    return QString();
}

bool FSOperations::createFolder(const QString &path)
{
    QDir dir(path);
    if (!dir.exists()) {
        return dir.mkpath(".");
    }
    return true;
}

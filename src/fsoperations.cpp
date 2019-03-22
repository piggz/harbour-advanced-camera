#include "fsoperations.h"
#include <QFile>

FSOperations::FSOperations(QObject *parent) : QObject(parent)
{

}

bool FSOperations::deleteFile(const QString &path)
{
    QFile f(path);
    return f.remove();
}

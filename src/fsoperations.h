#ifndef FSOPERATIONS_H
#define FSOPERATIONS_H

#include <QObject>

class FSOperations : public QObject
{
    Q_OBJECT
public:
    explicit FSOperations(QObject *parent = nullptr);
    Q_INVOKABLE bool deleteFile(const QString &path);
};

#endif // FSOPERATIONS_H

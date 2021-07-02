#include "deviceinfo.h"
#include <QDebug>
#include <QLibrary>

DeviceInfo::DeviceInfo()
{
    QLibrary lib;
    lib.setFileName("libssusysinfo.so.1");
    if (lib.load()) {
        qDebug() << "libssusysinfo.so.1 loaded";
        SsuAlloc allocFn = (SsuAlloc) lib.resolve("ssusysinfo_create");
        SsuDelete deleteFn = (SsuDelete) lib.resolve("ssusysinfo_delete");
        SsuManufacturer manufacturerFn = (SsuManufacturer) lib.resolve("ssusysinfo_device_manufacturer");
        SsuModel modelFn = (SsuModel) lib.resolve("ssusysinfo_device_pretty_name");

        if (allocFn && deleteFn && manufacturerFn && modelFn) {
            ssusysinfo_t *si = allocFn();
            if (si) {
                m_manufacturer = manufacturerFn(si);
                qDebug() << "manufacturer:" << m_manufacturer;
                m_prettyModelName = modelFn(si);
                qDebug() << "prettyModelName:" << m_prettyModelName;
                deleteFn(si);
            } else {
                qWarning() << "Cannot allocate ssusysinfo_t!";
            }
        } else {
            qWarning() << "Cannot resolve libssusysinfo methods!";
        }

        lib.unload();
    } else {
        qWarning() << "Unable to load libssusysinfo.so.1!";
    }
}

QString DeviceInfo::manufacturer() const
{
    return m_manufacturer;
}

QString DeviceInfo::prettyModelName() const
{
    return m_prettyModelName;
}


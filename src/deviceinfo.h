
#ifndef DEVICEINFO_H
#define DEVICEINFO_H

#include <QLibrary>

#include <ssusysinfo.h>

class DeviceInfo {
public:
    DeviceInfo();
    virtual ~DeviceInfo() = default;

    QString manufacturer() const;
    QString prettyModelName() const;

private:
    typedef ssusysinfo_t* (*SsuAlloc)();
    typedef char* (*SsuManufacturer)(ssusysinfo_t*);
    typedef char* (*SsuModel)(ssusysinfo_t*);
    typedef void (*SsuDelete)(ssusysinfo_t*);

    QString m_manufacturer;
    QString m_prettyModelName;
};

#endif //DEVICEINFO_H

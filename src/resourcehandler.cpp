#include "resourcehandler.h"
#include <dlfcn.h>
#include <QDebug>

void grant_callback(resource_set_t *, uint32_t, void *) {}

static resource_set_t *(*create_set)(const char*,uint32_t,uint32_t, uint32_t, resource_callback_t, void *);
static int (*acquire_set)(resource_set_t*);
static int (*release_set)(resource_set_t*);

ResourceHandler::ResourceHandler(QObject *parent) :
    QObject(parent)
{
    create_set = (resource_set_t* (*)(const char*, uint32_t, uint32_t, uint32_t, resource_callback_t, void*))dlsym(nullptr, "resource_set_create");
    acquire_set = (int (*)(resource_set_t*))dlsym(nullptr, "resource_set_acquire");
    release_set = (int (*)(resource_set_t*))dlsym(nullptr, "resource_set_release");
    m_resource = create_set("player", RESOURCE_SCALE_BUTTON, 0, 0, grant_callback, nullptr);
}

void ResourceHandler::acquire()
{
    acquire_set(m_resource);
}

void ResourceHandler::release()
{
    release_set(m_resource);
}

void ResourceHandler::handleFocusChange(QObject *focus)
{
    if (focus == nullptr) {
        release();
    } else {
        acquire();
    }
}

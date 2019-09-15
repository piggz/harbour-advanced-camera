#ifndef RESOURCEHANDLER_H
#define RESOURCEHANDLER_H

#include <QObject>

#define RESOURCE_BIT(b)   (((uint32_t)1) << (b))
#define RESOURCE_SCALE_BUTTON     RESOURCE_BIT( 10 )

typedef struct resource_set_t resource_set_t;
typedef void (*resource_callback_t)(resource_set_t *, uint32_t, void*);


class ResourceHandler : public QObject
{
    Q_OBJECT
public:
    explicit ResourceHandler(QObject *parent = 0);

public slots:
    void acquire();
    void release();
    void handleFocusChange(QObject* focus);

private:
    resource_set_t *m_resource;
    void *m_handle = nullptr;
};

#endif // RESOURCEHANDLER_H

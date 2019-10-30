#include "exifmodel.h"
#include <QDebug>
#include <QLibrary>

static void parseContent(ExifContent *content, void *userdata);
static void parseEntry(ExifEntry *entry, void *userdata);

typedef void (*ExifForEachEntry)(ExifContent*, ExifContentForeachEntryFunc, void*);
typedef void (*ExifGetValue)(ExifEntry*, char*, int);
typedef ExifIfd (*ExifGetIfd)(ExifContent*);
typedef char* (*ExifGetTag)(ExifTag, ExifIfd);
static ExifForEachEntry f_foreachentry;
static ExifGetValue f_getvalue;
static ExifGetIfd f_getifd;
static ExifGetTag f_gettag;

ExifModel::ExifModel()
{
}

ExifModel::~ExifModel()
{
    free(m_data);
    if (m_lib.isLoaded()) {
        m_lib.unload();
    }
}

bool ExifModel::loadLibexif()
{
    if (m_lib.isLoaded())
        return true;

    m_lib.setFileName("libexif.so.12");
    if (m_lib.load())
    {
        f_fromfile =  (ExifFromFile) m_lib.resolve("exif_data_new_from_file");
        f_getvalue = (ExifGetValue) m_lib.resolve("exif_entry_get_value");
        f_foreachentry = (ExifForEachEntry) m_lib.resolve("exif_content_foreach_entry");
        f_foreachcontent = (ExifForEachContent) m_lib.resolve("exif_data_foreach_content");
        f_getifd = (ExifGetIfd) m_lib.resolve("exif_content_get_ifd");
        f_gettag = (ExifGetTag) m_lib.resolve("exif_tag_get_name_in_ifd");
        f_dump = (ExifDump) m_lib.resolve("exif_data_dump");
    }
    else {
        qWarning() << "Unable to load libexif.so.12!";
        return false;
    }
    return true;
}

QHash<int, QByteArray> ExifModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[ExifName] = "name";
    roles[ExifValue] = "value";
    return roles;
}

int ExifModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent);
    return m_exif.count();
}

QVariant ExifModel::data(const QModelIndex &index, int role) const
{
    QVariant v;

    if (!index.isValid() || index.row() > rowCount(index) || index.row() < 0) {
        return v;
    }

    if (role == ExifValue) {
        v = m_exif.values().at(index.row());
    } else if (role == ExifName) {
        v = m_exif.keys().at(index.row());
    }

    return v;
}

void ExifModel::setSource(const QString &path)
{
    if (!loadLibexif())
        return;
    source = path;
    m_data = f_fromfile(path.toUtf8().data());
    //f_dump(m_data);
    beginResetModel();
    m_exif.clear();
    f_foreachcontent(m_data, parseContent, nullptr);
    endResetModel();
}

void parseContent(ExifContent *content, void *userdata)
{
    Q_UNUSED(userdata);
    f_foreachentry(content, parseEntry, content);
}

void parseEntry(ExifEntry *entry, void *userdata)
{
    ExifContent *content = static_cast<ExifContent *>(userdata);
    ExifIfd ifd = f_getifd(content);
    QString tag(f_gettag(entry->tag, ifd));
    char bufValue[1024];
    f_getvalue(entry, bufValue, 1024);
    m_exif.insert(tag, QString(bufValue));
}

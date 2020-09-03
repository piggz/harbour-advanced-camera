#ifndef EXIFMODEL_H
#define EXIFMODEL_H

#include <libexif/exif-data.h>
#include <QAbstractListModel>
#include <QLibrary>

static QMap<QString, QString> m_exif;

class ExifModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(QString source READ getSource WRITE setSource)
public:
    enum ExifRoles {
        ExifName = Qt::UserRole + 1,
        ExifValue
    };

    ExifModel();
    ~ExifModel();
    bool loadLibexif();
    QHash<int, QByteArray> roleNames() const;
    int rowCount(const QModelIndex &parent) const;
    QVariant data(const QModelIndex &index, int role) const;
    QString getSource() const { return source; }
    void setSource(const QString &path);
private:
    QString source;
    ExifData *m_data;
    QLibrary m_lib;
    typedef ExifData* (*ExifFromFile)(const char*);
    typedef void (*ExifForEachContent)(ExifData*, ExifDataForeachContentFunc, void*);
    typedef void (*ExifDump)(ExifData*);
    ExifFromFile f_fromfile;
    ExifForEachContent f_foreachcontent;
    ExifDump f_dump;
};

#endif // EXIFMODEL_H

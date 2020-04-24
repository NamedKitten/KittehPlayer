#ifndef ThumbnailCache_H
#define ThumbnailCache_H
#include <qdir.h>
#include <qobject.h>
#include <qobjectdefs.h>
#include <qstring.h>
class QNetworkAccessManager;

class ThumbnailCache : public QObject
{
  Q_OBJECT

public:
  explicit ThumbnailCache(QObject* parent = nullptr);

public slots:
  Q_INVOKABLE void addURL(const QString& name, const QString& url);

signals:
  void thumbnailReady(const QString& name,
                      const QString& url,
                      const QString& filePath);

private:
  QNetworkAccessManager* manager;
  QDir cacheFolder;
};
#endif
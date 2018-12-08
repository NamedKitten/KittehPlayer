#include "ThumbnailCache.h"
#include <QCryptographicHash>
#include <QImageReader>

ThumbnailCache::ThumbnailCache(QObject* parent)
  : QObject(parent)
  , manager(new QNetworkAccessManager(this))
{
  cacheFolder =
    QDir(QStandardPaths::writableLocation(QStandardPaths::CacheLocation) +
         "/thumbs");
  if (!cacheFolder.exists()) {
    cacheFolder.mkpath(".");
  }
}

void
ThumbnailCache::addURL(const QString& name, const QString& mediaURL)
{

  QString hashedURL = QString(
    QCryptographicHash::hash(name.toUtf8(), QCryptographicHash::Md5).toHex());
  QString cacheFilename = hashedURL + ".jpg";
  QString cachedFilePath = cacheFolder.absoluteFilePath(cacheFilename);
  if (cacheFolder.exists(cacheFilename)) {
    emit thumbnailReady(name, mediaURL, "file://" + cachedFilePath);
    return;
  }

  QString url(mediaURL);
  QFileInfo isFile = QFileInfo(url);
  if (isFile.exists()) {
    QImageReader reader(url);
    QImage image = reader.read();

    image.save(cachedFilePath, "JPG");

    emit thumbnailReady(name, mediaURL, "file://" + cachedFilePath);
    return;
  }

  QNetworkRequest request(url);

  QNetworkReply* reply = manager->get(request);

  connect(reply, &QNetworkReply::finished, [=] {
    QByteArray response_data = reply->readAll();

    QBuffer buffer(&response_data);
    buffer.open(QIODevice::ReadOnly);

    QImageReader reader(&buffer);
    QImage image = reader.read();

    image.save(cachedFilePath, "JPG");

    emit thumbnailReady(name, mediaURL, "file://" + cachedFilePath);
  });
}

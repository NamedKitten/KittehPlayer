#include <QApplication>
#include <QGuiApplication>
#include <QJsonDocument>
#include <QNetworkAccessManager>
#include <QObject>
#include <QProcessEnvironment>
#include <QQmlApplicationEngine>
#include <QSequentialIterable>
#include <QString>
#include <QVariant>
#include <QtCore>
#include <QtNetwork>

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

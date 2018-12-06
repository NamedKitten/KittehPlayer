#include "DirectMpvPlayerBackend.h"
#ifndef DISABLE_MpvPlayerBackend
#include "MpvPlayerBackend.h"
#endif

#include "enums.hpp"
#include "utils.hpp"
#include <cstdlib>

#include "enums.hpp"
#include <QApplication>
#include <QProcessEnvironment>
#include <QQmlApplicationEngine>
#include <QtCore>
#include <stdbool.h>

#ifdef WIN32
#include "setenv_mingw.hpp"
#endif

#ifdef GIT_COMMIT_HASH
#include <QJsonDocument>
#include <QSequentialIterable>
#include <QtNetwork>

#endif

#ifdef __linux__
#include <initializer_list>
#include <signal.h>
#include <unistd.h>
void
catchUnixSignals(std::initializer_list<int> quitSignals)
{
  auto handler = [](int sig) -> void { QCoreApplication::quit(); };

  sigset_t blocking_mask;
  sigemptyset(&blocking_mask);
  for (auto sig : quitSignals)
    sigaddset(&blocking_mask, sig);

  struct sigaction sa;
  sa.sa_handler = handler;
  sa.sa_mask = blocking_mask;
  sa.sa_flags = 0;

  for (auto sig : quitSignals)
    sigaction(sig, &sa, nullptr);
}
#endif

int
main(int argc, char* argv[])
{
#ifdef DISABLE_MpvPlayerBackend
  Enums::Backends backend = Enums::Backends::DirectMpvBackend;
#else
  Enums::Backends backend = Enums::Backends::MpvBackend;
#endif
  setenv("QT_QUICK_CONTROLS_STYLE", "Desktop", 1);
  QApplication app(argc, argv);
#ifdef __linux__
  catchUnixSignals({ SIGQUIT, SIGINT, SIGTERM, SIGHUP });
#endif

#ifdef GIT_COMMIT_HASH
  QString current_version = QString(GIT_COMMIT_HASH);
  qDebug() << "Current Version: " << current_version;

  QNetworkRequest request(QUrl("https://api.github.com/repos/NamedKitten/"
                               "KittehPlayer/releases/tags/continuous"));
  QNetworkAccessManager nam;
  QNetworkReply* reply = nam.get(request);

  while (!reply->isFinished()) {
    qApp->processEvents();
  }
  QByteArray response_data = reply->readAll();
  QJsonDocument json = QJsonDocument::fromJson(response_data);

  if (json["target_commitish"].toString().length() != 0) {
    if (json["target_commitish"].toString().endsWith(current_version) == 0) {
      qDebug() << "Latest Version: " << json["target_commitish"].toString();
      qDebug() << "Update Available. Please update ASAP.";
      QProcess notifier;
      notifier.setProcessChannelMode(QProcess::ForwardedChannels);
      notifier.start("notify-send",
                     QStringList() << "KittehPlayer"
                                   << "New update avalable!"
                                   << "--icon=KittehPlayer");
      notifier.waitForFinished();
    }
  } else {
    qDebug() << "Couldn't check for new version.";
  }
#endif

  app.setOrganizationName("KittehPlayer");
  app.setOrganizationDomain("namedkitten.pw");
  app.setApplicationName("KittehPlayer");

  QSettings settings;
  QString backendSetting = settings.value("Backend/backend", "").toString();
  if (backendSetting.length() == 0) {
#ifndef DISABLE_MpvPlayerBackend
    settings.setValue("Backend/backend", "mpv");
#else
    settings.setValue("Backend/backend", "direct-mpv");
#endif
  }

  qDebug() << backendSetting;

  for (int i = 1; i < argc; ++i) {
    if (!qstrcmp(argv[i], "--update")) {
      Utils::updateAppImage();
    } else if (!qstrcmp(argv[i], "--backend=mpv") || backendSetting == "mpv") {
      backend = Enums::Backends::MpvBackend;
    } else if (!qstrcmp(argv[i], "--backend=direct-mpv") ||
               backendSetting == "direct-mpv") {
      backend = Enums::Backends::DirectMpvBackend;
    }
  }

  Utils::SetDPMS(false);

  QString newpath =
    QProcessEnvironment::systemEnvironment().value("APPDIR", "") +
    "/usr/bin:" + QProcessEnvironment::systemEnvironment().value("PATH", "");
  setenv("PATH", newpath.toUtf8().constData(), 1);

  qmlRegisterUncreatableMetaObject(
    Enums::staticMetaObject, "player", 1, 0, "Enums", "Error: only enums");
  qRegisterMetaType<Enums::PlayStatus>("Enums.PlayStatus");
  qRegisterMetaType<Enums::VolumeStatus>("Enums.VolumeStatus");
  qRegisterMetaType<Enums::Backends>("Enums.Backends");
  qRegisterMetaType<Enums::Commands>("Enums.Commands");

  qmlRegisterType<UtilsClass>("player", 1, 0, "Utils");

  switch (backend) {
    case Enums::Backends::MpvBackend: {
#ifndef DISABLE_MpvPlayerBackend
      qmlRegisterType<MpvPlayerBackend>("player", 1, 0, "PlayerBackend");
#else
      qDebug() << "Normal MPV backend not available, resetting backend option "
                  "to blank.";
      settings.setValue("Backend/backend", "direct-mpv");
      app.exit();
#endif
      break;
    }
    case Enums::Backends::DirectMpvBackend: {
      qmlRegisterType<DirectMpvPlayerBackend>("player", 1, 0, "PlayerBackend");
      break;
    }
  }

  std::setlocale(LC_NUMERIC, "C");

  QQmlApplicationEngine engine;
  engine.load(QUrl(QStringLiteral("qrc:///main.qml")));

  return app.exec();
}

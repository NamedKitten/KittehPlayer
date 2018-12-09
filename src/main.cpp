#include "DirectMpvPlayerBackend.h"
#ifndef DISABLE_MpvPlayerBackend
#include "MpvPlayerBackend.h"
#endif

#include "enums.hpp"
#include "logger.h"
#include "utils.hpp"
#include <cstdlib>

#include "Process.h"
#include "enums.hpp"
#include <QApplication>
#include <QProcessEnvironment>
#include <QQmlApplicationEngine>
#include <QtConcurrent>
#include <QtCore>
#include <QtQml>
#include <stdbool.h>
#ifdef WIN32
#include "setenv_mingw.hpp"
#endif

#include "ThumbnailCache.h"

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

auto qmlLogger = initLogger("qml");
auto miscLogger = initLogger("misc");

void
spdLogger(QtMsgType type, const QMessageLogContext& context, const QString& msg)
{
  std::string localMsg = msg.toUtf8().constData();
  std::shared_ptr<spdlog::logger> logger;
  if (QString(context.category).startsWith(QString("qml"))) {
    logger = qmlLogger;
  } else {
    logger = miscLogger;
  }

  switch (type) {
    case QtDebugMsg:
      logger->debug("{}", localMsg);
      break;
    case QtInfoMsg:
      logger->info("{}", localMsg);
      break;
    case QtWarningMsg:
      logger->warn("{}", localMsg);
      break;
    case QtCriticalMsg:
      logger->critical("{}", localMsg);
      break;
    case QtFatalMsg:
      logger->critical("{}", localMsg);
      abort();
  }
}

int
main(int argc, char* argv[])
{

  qInstallMessageHandler(spdLogger);

  auto launcherLogger = initLogger("launcher");

  launcherLogger->info("Starting up!");

  QString backendString;
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

  app.setOrganizationName("KittehPlayer");
  app.setOrganizationDomain("namedkitten.pw");
  app.setApplicationName("KittehPlayer");

  QSettings settings;

  bool checkForUpdates =
    settings.value("Backend/checkForUpdatesOnLaunch", false).toBool();
  for (int i = 1; i < argc; ++i) {
    if (!qstrcmp(argv[i], "--no-update-check")) {
      checkForUpdates = false;
    }
  }

  if (checkForUpdates) {
    QtConcurrent::run(Utils::checkForUpdates);
  }

  QString backendSetting = settings.value("Backend/backend", "").toString();
  if (backendSetting.length() == 0) {
#ifndef DISABLE_MpvPlayerBackend
    settings.setValue("Backend/backend", "mpv");
#else
    settings.setValue("Backend/backend", "direct-mpv");
#endif
  }
  backendString = backendSetting;

  for (int i = 1; i < argc; ++i) {
    if (!qstrcmp(argv[i], "--update")) {
      Utils::updateAppImage();
    } else if (!qstrcmp(argv[i], "--backend=mpv") || backendSetting == "mpv") {
      backend = Enums::Backends::MpvBackend;
      backendString = QString("mpv");
    } else if (!qstrcmp(argv[i], "--backend=direct-mpv") ||
               backendSetting == "direct-mpv") {
      backendString = QString("direct-mpv");
      backend = Enums::Backends::DirectMpvBackend;
    }
  }

  launcherLogger->info("Using backend={}", backendString.toUtf8().constData());

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
  qmlRegisterType<Process>("player", 1, 0, "Process");

  qmlRegisterType<ThumbnailCache>("player", 1, 0, "ThumbnailCache");

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
  launcherLogger->info("Loading player...");

  QQmlApplicationEngine engine;
  engine.load(QUrl(QStringLiteral("qrc:///main.qml")));

  return app.exec();
}

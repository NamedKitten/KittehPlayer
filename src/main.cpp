#ifndef DISABLE_MpvPlayerBackend
#include "Backends/MPV/MPVBackend.hpp"
#endif

#include "enums.hpp"
#include "logger.h"
#include "qmldebugger.h"
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

  Enums::Backends backend;
  QString defaultBackend;
#ifdef DISABLE_MpvPlayerBackend
  defaultBackend = "direct-mpv";
#else
  defaultBackend = "mpv";
#endif
  setenv("QT_QUICK_CONTROLS_STYLE", "Desktop", 1);
  QApplication app(argc, argv);

  app.setOrganizationName("KittehPlayer");
  app.setOrganizationDomain("namedkitten.pw");
  app.setApplicationName("KittehPlayer");

#ifdef __linux__
  catchUnixSignals({ SIGQUIT, SIGINT, SIGTERM, SIGHUP });
#endif

  QSettings settings;

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

  qmlRegisterType<QMLDebugger>("player", 1, 0, "QMLDebugger");
  qmlRegisterType<ThumbnailCache>("player", 1, 0, "ThumbnailCache");

  qmlRegisterType<UtilsClass>("player", 1, 0, "Utils");
  qmlRegisterType<MPVBackend>("player", 1, 0, "PlayerBackend");


  setlocale(LC_NUMERIC, "C");
  launcherLogger->info("Loading player...");

  QQmlApplicationEngine engine;
  engine.load(QUrl(QStringLiteral("qrc:///main.qml")));

  return app.exec();
}

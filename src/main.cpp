#include <QtGlobal>
#include <locale.h>
#include <QApplication>
#include <QProcess>
#include <QtQml>
#include <QQmlApplicationEngine>
#ifdef QT_QML_DEBUG
#include <QQmlDebug>
#endif
#include <QSettings>
#include <QString>
#include <QUrl>
#include <QVariant>
#include <spdlog/fmt/fmt.h>
#include <cstdlib>
#include <exception>
#include <iosfwd>
#include <memory>
#ifndef DISABLE_MPV_RENDER_API
#include "Backends/MPV/MPVBackend.hpp"
#endif
#include "Backends/MPVNoFBO/MPVNoFBOBackend.hpp"
#include "Process.h"
#include "ThumbnailCache.h"
#include "enums.hpp"
#include "logger.h"
#include "qmldebugger.h"
#include "spdlog/logger.h"
#include "utils.hpp"

#ifdef WIN32
#include "setenv_mingw.hpp"
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

  setenv("QT_QUICK_CONTROLS_STYLE", "Desktop", 1);
  QApplication app(argc, argv);

  app.setOrganizationName("KittehPlayer");
  app.setOrganizationDomain("kitteh.pw");
  app.setApplicationName("KittehPlayer");

#ifdef QT_QML_DEBUG
  // Allows debug.
  QQmlDebuggingEnabler enabler;
#endif

  QSettings settings;
  Utils::SetDPMS(false);

#ifdef __linux__
  catchUnixSignals({ SIGQUIT, SIGINT, SIGTERM, SIGHUP }); 

  // WARNING, THIS IS A BIG HACK
  // this is only to make it so KittehPlayer works first try on pinephone.
  // TODO: launch a opengl window or use offscreen to see if GL_ARB_framebuffer_object
  // can be found
  if (! settings.value("Backend/disableSunxiCheck", false).toBool()) {
    FILE *fd = popen("grep sun[x8]i /proc/modules", "r");
    char buf[16];
    if (fread(buf, 1, sizeof (buf), fd) > 0) {
      launcherLogger->info("Running on sunxi, switching to NoFBO.");
      settings.setValue("Backend/fbo", false);
      settings.setValue("Appearance/clickToPause", false);
      settings.setValue("Appearance/doubleTapToSeek", true);
      settings.setValue("Appearance/scaleFactor", 2.2);
      settings.setValue("Appearance/subtitlesFontSize", 38);
      settings.setValue("Appearance/uiFadeTimer", 0);
    }
  }

#endif


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

#ifndef DISABLE_MPV_RENDER_API
  if (settings.value("Backend/fbo", true).toBool()) {
    qmlRegisterType<MPVBackend>("player", 1, 0, "PlayerBackend");
  } else {
    qmlRegisterType<MPVNoFBOBackend>("player", 1, 0, "PlayerBackend");
  }
#else
  qmlRegisterType<MPVNoFBOBackend>("player", 1, 0, "PlayerBackend");
#endif
  setlocale(LC_NUMERIC, "C");
  launcherLogger->info("Loading player...");

  QQmlApplicationEngine engine;
  engine.load(QUrl(QStringLiteral("qrc:///main.qml")));

  return app.exec();
}

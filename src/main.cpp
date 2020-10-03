#include <QApplication>
#include <QProcess>
#include <QQmlApplicationEngine>
#include <QtGlobal>
#include <QtQml>
#include <locale.h>
#ifdef QT_QML_DEBUG
#warning "QML Debugging Enabled!!!"
#include <QQmlDebug>
#endif
#include "logger.h"
#include "spdlog/logger.h"
#include <QSettings>
#include <QString>
#include <QUrl>
#include <QVariant>
#include <cstdlib>
#include <exception>
#include <iosfwd>
#include <memory>
#include <spdlog/fmt/fmt.h>

extern void registerTypes();

#ifdef WIN32
#include "setenv_mingw.hpp"
#endif

auto qmlLogger = initLogger("qml");
auto miscLogger = initLogger("misc");

void spdLogger(QtMsgType type, const QMessageLogContext& context, const QString& msg)
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

int main(int argc, char* argv[])
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

    bool ranFirstTimeSetup = settings.value("Setup/ranSetup", false).toBool();

#ifdef __linux__
    bool pinephone;
#ifdef PINEPHONE
    pinephone = true;
#else
    pinephone = false;
#endif

    // There once was a hacky piece of a code, now its gone.
    // TODO: launch a opengl window or use offscreen to see if GL_ARB_framebuffer_object
    // can be found
    if (!(settings.value("Backend/disableSunxiCheck", false).toBool() || ranFirstTimeSetup) || pinephone ) {
		std::string buf;
		std::ifstream modulesFd;

		modulesFd.open("/proc/modules");

		if(modulesFd.is_open()) {
			while(!modulesFd.eof()) {
				std::getline(modulesFd, buf);
				if(buf.find("sunxi") != std::string::npos || buf.find("sun8i") != std::string::npos) {
					launcherLogger->info("Running on sunxi, switching to NoFBO.");
					settings.setValue("Appearance/clickToPause", false);
					settings.setValue("Appearance/doubleTapToSeek", true);
					settings.setValue("Appearance/scaleFactor", 2.2);
					settings.setValue("Appearance/subtitlesFontSize", 38);
					settings.setValue("Appearance/uiFadeTimer", 0);
					settings.setValue("Backend/fbo", false);
				}
			}
		} else {
			launcherLogger->info("(THIS IS NOT AN ERROR) Cant open /proc/modules.");
		}
    }
#endif

    settings.setValue("Setup/ranSetup", true);

    QString newpath = QProcessEnvironment::systemEnvironment().value("APPDIR", "") + "/usr/bin:" + QProcessEnvironment::systemEnvironment().value("PATH", "");
    setenv("PATH", newpath.toUtf8().constData(), 1);

    registerTypes();

    setlocale(LC_NUMERIC, "C");
    launcherLogger->info("Loading player...");

    QQmlApplicationEngine engine;
    engine.load(QUrl(QStringLiteral("qrc:///main.qml")));

    return app.exec();
}

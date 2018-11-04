#ifdef QRC_SOURCE_PATH
#include "runtimeqml/runtimeqml.h"
#endif

#include <cstdlib>


#include <QApplication>
#include <QQmlApplicationEngine>
#include <QProcessEnvironment>
#include "MpvPlayerBackend.h"

#ifdef WIN32
#include "setenv_mingw.hpp"
#endif

int main( int argc, char *argv[] )
{
#ifdef WINDOWS
setenv("QT_QPA_PLATFORM_PLUGIN_PATH",  "plugins\platforms", 0)
#else
setenv("QT_QPA_PLATFORMTHEME", "gtk3", 0);
#endif
    setenv("QT_QUICK_CONTROLS_STYLE","Desktop",1);
    QApplication app(argc, argv);
    app.setOrganizationName("KittehPlayer");
    app.setOrganizationDomain("namedkitten.pw");
    app.setApplicationName("KittehPlayer");
    for (int i = 1; i < argc; ++i) {
        if (!qstrcmp(argv[i], "--update")) {
            QString program = QProcessEnvironment::systemEnvironment().value("APPDIR", "") +  "/usr/bin/appimageupdatetool";
            QProcess updater;
            updater.setProcessChannelMode(QProcess::ForwardedChannels);
            updater.start(program, QStringList() << QProcessEnvironment::systemEnvironment().value("APPIMAGE", ""));
            updater.waitForFinished();
            qDebug() << program;
            exit(0);
        }
    }
    
    QProcess dpms;
    dpms.start("xset", QStringList() << "-dpms");

    QString newpath = QProcessEnvironment::systemEnvironment().value("APPDIR", "") + "/usr/bin:" + QProcessEnvironment::systemEnvironment().value("PATH", "");
    qDebug() << newpath;
    setenv("PATH", newpath.toUtf8().constData(), 1);

    QApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    qmlRegisterType<MpvPlayerBackend>("player", 1, 0, "PlayerBackend");
    std::setlocale(LC_NUMERIC, "C");

    QQmlApplicationEngine engine;
#ifdef QRC_SOURCE_PATH
RuntimeQML *rt = new RuntimeQML(&engine, QRC_SOURCE_PATH"/qml.qrc");

rt->setAutoReload(true);
rt->setMainQmlFilename("main.qml");
rt->reload();
#else
engine.load(QUrl(QStringLiteral("qrc:///player/main.qml")));
#endif

    return app.exec();
}

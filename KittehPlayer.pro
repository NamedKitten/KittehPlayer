TARGET = KittehPlayer

TEMPLATE = app
QT += qml quickcontrols2 widgets x11extras

SOURCES += src/main.cpp src/MpvPlayerBackend.cpp src/utils.cpp

CONFIG += debug
CONFIG-=qtquickcompiler
QT_CONFIG -= no-pkg-config
CONFIG += link_pkgconfig
PKGCONFIG += mpv
RESOURCES += src/qml/qml.qrc

unix {
    isEmpty {
        PREFIX = /usr
    }
    PKGCONFIG += x11 xext

    target.path = $$PREFIX/bin

    desktop.files = KittehPlayer.desktop
    desktop.path = $$PREFIX/share/applications/
    icon.files += KittehPlayer.png
    icon.path = $$PREFIX/share/icons/hicolor/256x256/apps/

    INSTALLS += desktop
    INSTALLS += icon
}

INSTALLS += target

HEADERS += src/MpvPlayerBackend.h src/utils.hpp


DISTFILES += KittehPlayer.desktop KittehPlayer.png README.md LICENSE.txt

#!/bin/bash

set -ex

export PATH="/usr/lib/ccache:/usr/lib/ccache/bin:$PATH"

export QML_SOURCES_PATHS=src/qml
export V=0 VERBOSE=0

cmake -DCMAKE_INSTALL_PREFIX=/usr .
make -j$(nproc)
make DESTDIR=appdir -j$(nproc) install ; find appdir/
wget -nc "https://github.com/linuxdeploy/linuxdeploy/releases/download/continuous/linuxdeploy-x86_64.AppImage"
wget -nc "https://github.com/linuxdeploy/linuxdeploy-plugin-qt/releases/download/continuous/linuxdeploy-plugin-qt-x86_64.AppImage"
chmod +x linux*
mkdir -p appdir/usr/lib

if [ "$ARCH" == "" ]; then
    ARCH="x86_64"
fi
wget `curl -s https://api.github.com/repos/AppImage/AppImageUpdate/releases | grep browser_download_url | grep x86_64.AppImage | grep appimageupdatetool | grep -v zsync | cut -d'"' -f4` -O appdir/usr/bin/appimageupdatetool
chmod +x appdir/usr/bin/appimageupdatetool

wget https://yt-dl.org/downloads/latest/youtube-dl -O appdir/usr/bin/youtube-dl
chmod +x appdir/usr/bin/youtube-dl

export UPD_INFO="gh-releases-zsync|NamedKitten|KittehPlayer|continuous|KittehPlayer-$ARCH.AppImage.zsync"
time ./linuxdeploy-x86_64.AppImage --appdir appdir --plugin qt --output appimage -v 3

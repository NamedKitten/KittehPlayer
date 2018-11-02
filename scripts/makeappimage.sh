#!/bin/bash

set -ex

export PATH="/usr/lib/ccache:/usr/lib/ccache/bin:$PATH"

export QML_SOURCES_PATHS=src/qml
export V=0 VERBOSE=0

cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr .
make -j$(nproc)
make DESTDIR=appdir -j$(nproc) install ; find appdir/
wget -nc "https://github.com/linuxdeploy/linuxdeploy/releases/download/continuous/linuxdeploy-x86_64.AppImage"
wget -nc "https://github.com/linuxdeploy/linuxdeploy-plugin-qt/releases/download/continuous/linuxdeploy-plugin-qt-x86_64.AppImage"
chmod +x linux*
mkdir -p appdir/usr/lib

if [ "$ARCH" == "" ]; then
    ARCH="x86_64"
fi

git clone https://github.com/AppImage/AppImageUpdate.git
cd AppImageUpdate
ver=`printf "appimageupdatetool-%s-%s-x86_64.AppImage" "$(git rev-list --count HEAD)" "$(git rev-parse --short HEAD)"`
#git submodule update --init --recursive
#cmake . -DCMAKE_INSTALL_PREFIX=/usr
#make 
#sudo make install
sudo wget https://github.com/AppImage/AppImageUpdate/releases/download/continuous/${ver} -O /usr/bin/appimageupdatetool
chmod +x /usr/bin/appimageupdatetool
cd ..

cp /usr/bin/appimageupdatetool appdir/usr/bin

cp -f /usr/lib/*/libjack.so.0 appdir/usr/lib

sudo pip3 install pyinstaller || true
sudo wget https://yt-dl.org/downloads/latest/youtube-dl -O ytdl.zip || true
unzip ytdl.zip || true
pyinstaller __main__.py -n youtube-dl --onefile || true
cp dist/youtube-dl appdir/usr/bin || true

export UPD_INFO="gh-releases-zsync|NamedKitten|KittehPlayer|continuous|KittehPlayer-$ARCH.AppImage.zsync"
export EXTRA_QT_PLUGINS="qgtk3"
./linuxdeploy-x86_64.AppImage --appdir appdir --plugin qt --output appimage -v 3

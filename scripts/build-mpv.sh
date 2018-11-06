#!/bin/bash
set -x

export OLDDIR=`pwd`
export PATH="/usr/lib/ccache:/usr/lib/ccache/bin:$PATH"

export CFLAGS="-Os -pipe"

#rm -rf mpv-build
git clone --depth 1 https://github.com/mpv-player/mpv-build mpv-build
cd mpv-build

export MPVDIR=`pwd`

rm -rf ffmpeg mpv libass

echo "--disable-programs --disable-runtime-cpudetect --disable-asm --enable-small" > ffmpeg_options
echo "--enable-libmpv-shared --prefix=/usr --disable-vapoursynth --enable-lgpl" > mpv_options
echo "--disable-cplayer --disable-caca --disable-wayland --disable-gl-wayland --disable-libarchive  --disable-zlib --disable-tv --disable-debug-build --disable-manpage-build --disable-libsmbclient --disable-wayland --disable-sdl --disable-sndio --enable-plain-gl" >> mpv_options

./rebuild -j`nproc`
sudo ./install
ccache -s

cd mpv
python waf -v install --destdir=destdir
cd destdir
tar caf mpv.tar * 
wget https://github.com/probonopd/uploadtool/raw/master/upload.sh
bash upload.sh mpv.tar

cd $OLDDIR

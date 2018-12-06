# KittehPlayer
A YouTube-like video player based on Qt, QML and libmpv. 

## How to install
### Windows
- Coming Soon:tm:

### Distro Packages
- Arch Linux: `kittehplayer` in the AUR

### Linux AppImage
- You can find the latest appimage of KittehPlayer automatically built by travis at: https://github.com/NamedKitten/KittehPlayer/releases
- To easily install it so it can be easily updated run as your current user:
```
sudo wget https://github.com/NamedKitten/KittehPlayer/releases/download/continuous/KittehPlayer-x86_64.AppImage -O /usr/bin/KittehPlayer && sudo chmod +x /usr/bin/KittehPlayer && sudo chown $USER /usr/bin/KittehPlayer
```
- To update the AppImage run `KittehPlayer --update` periodically which will update it using as little bandwidth as needed. 


### From source
#### Dependencies
##### Arch Linux
```
pacman -S git cmake qt5-svg qt5-declarative qt5-quickcontrols qt5-quickcontrols2 mpv
```
##### Ubuntu Xenial 
``` 
sudo add-apt-repository ppa:beineri/opt-qt-5.11.1-xenial -y
sudo apt update
sudo apt install build-essential git nasm qt511-meta-minimal qt511quickcontrols qt511quickcontrols2 qt511imageformats qt511svg libgl1-mesa-dev libmpv-dev
sudo apt-get build-dep mpv libmpv* ffmpeg
```
#### Instructions 
- `git clone https://github.com/NamedKitten/KittehPlayer KittehPlayer`
- `cd KittehPlayer`
- `mkdir build && cd build`
- `cmake .. -DCMAKE_INSTALL_PREFIX=/usr`
- `make`
- `sudo make install`
- The finished player will then be installed and you can launch it using `KittehPlayer`

## Configuration
- For docs on KittehPlayer please view DOCS.md or `man KittehPlayer`

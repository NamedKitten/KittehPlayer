# KittehPlayer

![made with c++](https://forthebadge.com/images/badges/made-with-c-plus-plus.svg)

![works 60 percent of the time every time](https://forthebadge.com/images/badges/60-percent-of-the-time-works-every-time.svg)

![libmpv 2.29+](https://img.shields.io/badge/libmpv-2.29+-blue.svg?logo=qt&style=for-the-badge)

![qt 5.12](https://img.shields.io/badge/Qt-5.12-41cd52.svg?logo=qt&style=for-the-badge)


A video player based on Qt, QML and libmpv with themes for many online video players.. 

## Themes
- YouTube ![YouTube Screenshot](https://raw.githubusercontent.com/purringChaos/KittehPlayer/master/screenshots/YouTube.png)
- NicoNico ![NicoNico Screenshot](https://raw.githubusercontent.com/purringChaos/KittehPlayer/master/screenshots/NicoNico.png)
- RoosterTeeth ![RoosterTeeth Screenshot](https://raw.githubusercontent.com/purringChaos/KittehPlayer/master/screenshots/RoosterTeeth.png)

## FOR PINEPHONE USERS
- If you use a pinephone, you MIGHT need config from the gist linked at very bottom.


## How to install
### Windows
- Coming Soon:tm:

### Distro Packages
- None right now, if you want to then pop me a message on somewhere linked on [My Website](https://kitteh.pw/) and I'll be happy to help if stuff goes wrong.

### From source
#### Dependencies
##### Arch Linux
```
pacman -S git cmake qt5-svg qt5-declarative qt5-quickcontrols qt5-quickcontrols2 qt5-graphicaleffects mpv
```
##### Ubuntu Bionic
```
sudo add-apt-repository ppa:beineri/opt-qt-5.12.6-bionic -y
sudo apt update
sudo apt install build-essential git qt512-meta-minimal qt512quickcontrols qt512quickcontrols2 qt512svg qt512x11extras qt512graphicaleffects qt512svg libgl1-mesa-dev libmpv-dev
```
##### Debian
```
sudo apt install build-essential cmake qtquickcontrols2-5-dev qtbase5-dev qtdeclarative5-dev libqt5x11extras5-dev libmpv-dev qml-module-qtquick-controls qml-module-qtquick-controls2 qml-module-qtquick-extras qml-module-qtquick-layouts qml-module-qtquick-dialogs qml-module-qtquick-privatewidgets qml-module-qtquick-localstorage qml-module-qt-labs-settings qml-module-qt-labs-platform qtbase5-private libqt5svg5
```
- Note that I don't know if this is the full list yet, pop a issue up if building fails.

#### Instructions 
- `git clone https://github.com/purringChaos/KittehPlayer KittehPlayer`
- `cd KittehPlayer`
- `mkdir build && cd build`
- If you are on ubuntu bionic, run `source /opt/qt512/bin/qt512-env.sh` and add `-DOLD_UBUNTU=on` to the cmake command next.
- `cmake .. -DCMAKE_INSTALL_PREFIX=/usr`
- `make`
- `sudo make install`
- The finished player will then be installed and you can launch it using `KittehPlayer`

## Configuration
- For docs on KittehPlayer please view DOCS.md or `man KittehPlayer`
- If you get a white screen when trying to play a video see [Here](https://gist.github.com/purringChaos/675ca8587a8f714a856c6d6d14a9562a) for a config that may work.
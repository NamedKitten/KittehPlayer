#ifndef ENUMS_HPP
#define ENUMS_HPP

#include <qobject.h>
#include <qobjectdefs.h>
#include <qstring.h>

namespace Enums {
Q_NAMESPACE
enum class PlayStatus : int
{
  Playing = 0,
  Paused = 1
};
Q_ENUM_NS(PlayStatus)
enum class VolumeStatus : int
{
  Muted = 0,
  Low = 1,
  Normal = 2
};
Q_ENUM_NS(VolumeStatus)
enum class Commands : int
{
  TogglePlayPause = 0,
  ToggleMute = 1,
  SetAudioDevice = 2,
  AddVolume = 3,
  SetVolume = 4,
  AddSpeed = 5,
  SubtractSpeed = 6,
  ChangeSpeed = 7,
  SetSpeed = 8,
  ToggleStats = 9,
  NextAudioTrack = 10,
  NextVideoTrack = 11,
  NextSubtitleTrack = 12,
  PreviousPlaylistItem = 13,
  NextPlaylistItem = 14,
  LoadFile = 15,
  AppendFile = 16,
  Seek = 17,
  SeekAbsolute = 18,
  ForwardFrame = 19,
  BackwardFrame = 20,
  SetTrack = 21,
  SetPlaylistPos = 22,
  ForcePause = 23,
};
Q_ENUM_NS(Commands)

enum class Backends : int
{
  MPVBackend = 0,
  DirectMPVBackend = 1
};
Q_ENUM_NS(Backends)

}

// Forces meta generation.
class Dummy : public QObject
{
  Q_OBJECT
};

#endif

#ifndef ENUMS_HPP
#define ENUMS_HPP

#include <QObject>
#include <QtGlobal>

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
  GetAudioDevices = 3,
  AddVolume = 4,
  SetVolume = 5,
  AddSpeed = 6,
  SubtractSpeed = 7,
  ChangeSpeed = 8,
  SetSpeed = 9,
  ToggleStats = 10,
  NextAudioTrack = 11,
  NextVideoTrack = 12,
  NextSubtitleTrack = 13,
  PreviousPlaylistItem = 14,
  NextPlaylistItem = 15,
  LoadFile = 16,
  AppendFile = 17,
  Seek = 18,
  SeekAbsolute = 19,
  GetTracks = 20,
  ForwardFrame = 21,
  BackwardFrame = 22,
  SetTrack = 23
};
Q_ENUM_NS(Commands)
}

#endif

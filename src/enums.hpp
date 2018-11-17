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
}

#endif

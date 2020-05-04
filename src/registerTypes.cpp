#ifndef DISABLE_MPV_RENDER_API
#include "Backends/MPV/MPVBackend.hpp"
#endif
#include "Backends/MPVNoFBO/MPVNoFBOBackend.hpp"
#include "Process.h"
#include "ThumbnailCache.h"
#include "enums.hpp"
#include "qmldebugger.h"
#include "utils.hpp"
#include <QSettings>

void registerTypes() {
  QSettings settings;


  qmlRegisterUncreatableMetaObject(
    Enums::staticMetaObject, "player", 1, 0, "Enums", "Error: only enums");
  qRegisterMetaType<Enums::PlayStatus>("Enums.PlayStatus");
  qRegisterMetaType<Enums::VolumeStatus>("Enums.VolumeStatus");
  qRegisterMetaType<Enums::Backends>("Enums.Backends");
  qRegisterMetaType<Enums::Commands>("Enums.Commands");
  qmlRegisterType<Process>("player", 1, 0, "Process");

  qmlRegisterType<QMLDebugger>("player", 1, 0, "QMLDebugger");
  qmlRegisterType<ThumbnailCache>("player", 1, 0, "ThumbnailCache");

  qmlRegisterType<UtilsClass>("player", 1, 0, "Utils");

#ifndef DISABLE_MPV_RENDER_API
  if (settings.value("Backend/fbo", true).toBool()) {
    qmlRegisterType<MPVBackend>("player", 1, 0, "PlayerBackend");
  } else {
    qmlRegisterType<MPVNoFBOBackend>("player", 1, 0, "PlayerBackend");
  }
#else
  qmlRegisterType<MPVNoFBOBackend>("player", 1, 0, "PlayerBackend");
#endif
}
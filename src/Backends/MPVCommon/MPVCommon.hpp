#ifndef MPVCommon_H
#define MPVCommon_H

#include "src/enums.hpp"
#include <QMetaType>
#include <QString>
#include <QVariant>
#include <mpv/client.h>
class BackendInterface;
class QMetaMethod;

namespace MPVCommon {

QString getStats(BackendInterface* b);
QVariant playerCommand(BackendInterface* b, const Enums::Commands& cmd, const QVariant& args);
void updateDurationString(BackendInterface* b, int numTime, QMetaMethod metaMethod);
void handle_mpv_event(BackendInterface* b, mpv_event* event);
QVariantMap getAudioDevices(const QVariant& drivers);
}

#endif
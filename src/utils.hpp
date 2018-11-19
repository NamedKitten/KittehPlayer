#ifndef UTILS_H
#define UTILS_H
#include <QWindow>
#include <stdbool.h>

namespace Utils {
void
SetDPMS(bool on);
void
AlwaysOnTop(WId wid, bool on);
void
updateAppImage();
QString
createTimestamp(int seconds);
}
#endif

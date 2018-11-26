#ifndef UTILS_H
#define UTILS_H
#include <QObject>
#include <QWindow>
#include <QtGlobal>
#include <stdbool.h>

namespace Utils {
Q_NAMESPACE
void
SetDPMS(bool on);
void
AlwaysOnTop(WId wid, bool on);
void
updateAppImage();
QString
createTimestamp(int seconds);
void
ResetScreensaver();
}

class UtilsClass : public QObject
{
  Q_OBJECT
public slots:
  void SetDPMS(bool on) { Utils::SetDPMS(on); };
  void AlwaysOnTop(WId wid, bool on) { Utils::AlwaysOnTop(wid, on); };
  void updateAppImage() { Utils::updateAppImage(); };
  QString createTimestamp(int seconds)
  {
    return Utils::createTimestamp(seconds);
  };
  void ResetScreensaver() { Utils::ResetScreensaver(); };
};

#endif

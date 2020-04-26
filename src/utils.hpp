#ifndef UTILS_H
#define UTILS_H
#include <QObject>
#include <QString>
#include <QWindow>

namespace Utils {
Q_NAMESPACE
void
SetDPMS(bool on);
void
SetScreensaver(WId wid, bool on);
void
AlwaysOnTop(WId wid, bool on);
QString
createTimestamp(int seconds);
void
launchAboutQt();
}

class UtilsClass : public QObject
{
  Q_OBJECT
public slots:
  void SetDPMS(bool on) { Utils::SetDPMS(on); };
  void AlwaysOnTop(WId wid, bool on) { Utils::AlwaysOnTop(wid, on); };
  void launchAboutQt() { Utils::launchAboutQt(); };

  QString createTimestamp(int seconds)
  {
    return Utils::createTimestamp(seconds);
  };
};

#endif

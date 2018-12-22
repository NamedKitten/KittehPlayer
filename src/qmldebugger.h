#ifndef QMLDEBUGGER_H
#define QMLDEBUGGER_H

#include <QObject>
#include <QQuickItem>

class QMLDebugger : public QObject
{
  Q_OBJECT
public:
  Q_INVOKABLE static QString properties(QQuickItem* item,
                                        bool linebreak = true);
};

#endif // QMLDEBUGGER_H

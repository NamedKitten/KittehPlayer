#ifndef Process_H
#define Process_H

#include <qmetatype.h>
#include <qobjectdefs.h>
#include <qprocess.h>
#include <qstring.h>
class QObject;

class Process : public QProcess
{
  Q_OBJECT

public:
  explicit Process(QObject* parent = 0);

  Q_INVOKABLE void start(const QString& program, const QVariantList& arguments);

  Q_INVOKABLE QString getOutput();
};
#endif
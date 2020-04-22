#include "Process.h"
#include <qstringlist.h>
#include <qvariant.h>
class QObject;

Process::Process(QObject* parent)
  : QProcess(parent)
{}

void
Process::start(const QString& program, const QVariantList& arguments)
{
  QStringList args;

  for (int i = 0; i < arguments.length(); i++)
    args << arguments[i].toString();

  QProcess::start(program, args);
}

QString
Process::getOutput()
{
  return QProcess::readAllStandardOutput();
}

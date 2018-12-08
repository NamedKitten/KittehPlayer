#include <QProcess>
#include <QVariant>

class Process : public QProcess
{
  Q_OBJECT

public:
  explicit Process(QObject* parent = 0);

  Q_INVOKABLE void start(const QString& program, const QVariantList& arguments);

  Q_INVOKABLE QString getOutput();
};

#ifndef Process_H
#define Process_H

#include <QMetaType>
#include <QObject>
#include <QProcess>
#include <QString>

class Process : public QProcess {
    Q_OBJECT

public:
    explicit Process(QObject* parent = 0);

    Q_INVOKABLE void start(const QString& program, const QVariantList& arguments);

    Q_INVOKABLE QString getOutput();
};
#endif
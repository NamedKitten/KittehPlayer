#ifndef LOGGER_HPP
#define LOGGER_HPP
#include <spdlog/spdlog.h>

#include <spdlog/sinks/basic_file_sink.h>
#include <spdlog/sinks/daily_file_sink.h>
#include <spdlog/sinks/stdout_color_sinks.h>

#include <QProcessEnvironment>
#include <QQmlApplicationEngine>
#include <QSequentialIterable>
#include <QString>
#include <QVariant>
#include <QtCore>
#include <QtNetwork>

std::shared_ptr<spdlog::logger>
initLogger(std::string name);

#endif

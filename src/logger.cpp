#include "logger.h"

#include <QObject>
#include <QString>
#include <iostream>

std::shared_ptr<spdlog::logger>
initLogger(std::string name)
{
  std::vector<spdlog::sink_ptr> sinks;
  sinks.push_back(std::make_shared<spdlog::sinks::stdout_color_sink_mt>());
  sinks.push_back(std::make_shared<spdlog::sinks::basic_file_sink_mt>(
    "/tmp/KittehPlayer.log"));
  auto console =
    std::make_shared<spdlog::logger>(name, begin(sinks), end(sinks));
  console->set_pattern("%^[%d-%m-%Y %T.%e][%l][%n] %v%$");

  spdlog::register_logger(console);

  return spdlog::get(name);
}

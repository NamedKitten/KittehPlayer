#ifndef LOGGER_HPP
#define LOGGER_HPP
#include <iosfwd>                            // IWYU pragma: keep
#include <memory>                            // IWYU pragma: keep
#include <spdlog/sinks/basic_file_sink.h>    // IWYU pragma: keep
#include <spdlog/sinks/daily_file_sink.h>    // IWYU pragma: keep
#include <spdlog/sinks/stdout_color_sinks.h> // IWYU pragma: keep
#include <spdlog/spdlog.h>                   // IWYU pragma: keep

std::shared_ptr<spdlog::logger>
initLogger(std::string name);

#endif

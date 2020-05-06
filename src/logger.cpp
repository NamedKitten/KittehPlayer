#include "spdlog/common.h"
#include "spdlog/details/file_helper-inl.h"
#include "spdlog/sinks/ansicolor_sink-inl.h"
#include "spdlog/sinks/base_sink-inl.h"
#include "spdlog/sinks/basic_file_sink-inl.h"
#include "spdlog/spdlog-inl.h"
#include <QByteArray>
#include <QSettings>
#include <QString>
#include <QVariant>
#include <iosfwd> // IWYU pragma: keep
#include <iterator>
#include <memory> // IWYU pragma: keep
#include <spdlog/logger.h>
#include <spdlog/sinks/basic_file_sink.h> // IWYU pragma: export
#include <spdlog/sinks/daily_file_sink.h> // IWYU pragma: export
#include <spdlog/sinks/stdout_color_sinks.h> // IWYU pragma: export
#include <spdlog/spdlog.h> // IWYU pragma: export
#include <vector>

std::shared_ptr<spdlog::logger>
initLogger(std::string name)
{
    QSettings settings("KittehPlayer", "KittehPlayer");

    QString logFile = settings.value("Logging/logFile", "/tmp/KittehPlayer.log").toString();

    std::vector<spdlog::sink_ptr> sinks;
    sinks.push_back(std::make_shared<spdlog::sinks::stdout_color_sink_mt>());
    sinks.push_back(std::make_shared<spdlog::sinks::basic_file_sink_mt>(
        logFile.toUtf8().constData()));
    auto console = std::make_shared<spdlog::logger>(name, begin(sinks), end(sinks));
    console->set_pattern("[%l][%n] %v%$");
    spdlog::register_logger(console);

    return spdlog::get(name);
}

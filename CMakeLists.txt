cmake_minimum_required(VERSION 3.5.1)

project(KittehPlayer)
include_directories(${CMAKE_SOURCE_DIR} ${CMAKE_BINARY_DIR}) 
set(CMAKE_AUTOMOC ON)

include(ExternalProject)


find_package(Qt5Core REQUIRED)
find_package(Qt5Gui REQUIRED)
find_package(Qt5Concurrent REQUIRED)

find_package(Qt5 CONFIG REQUIRED COMPONENTS Qml Quick Gui Widgets Core X11Extras)

find_package(Qt5QuickCompiler)
#if(Qt5QuickCompiler_FOUND)
#qtquick_compiler_add_resources(qml_QRC src/qml/qml.qrc)
#else()
qt5_add_resources(qml_QRC src/qml/qml.qrc)
#endif()

find_package(PkgConfig)
pkg_check_modules(MPV REQUIRED mpv)
pkg_check_modules(X11 x11)
pkg_check_modules(Xext xext)


execute_process(
  COMMAND git clone --depth 1 https://github.com/gabime/spdlog.git
  WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
)

include_directories(${CMAKE_BINARY_DIR}/spdlog/include)



if(X11_FOUND AND Xext_FOUND)
add_definitions(-DENABLE_X11)
endif(X11_FOUND AND Xext_FOUND)

link_directories(/usr/local/lib)
    #src/Backends/DirectMPV/DirectMPVBackend.cpp

set(SOURCES
    src/main.cpp
    src/utils.cpp
    src/enums.cpp
    src/Process.cpp
    src/ThumbnailCache.cpp
    src/logger.cpp
    src/qmldebugger.cpp
    src/Backends/MPV/MPVBackend.cpp
    src/Backends/MPVNoFBO/MPVNoFBOBackend.cpp
)

find_program(CCACHE_FOUND cache)
if(CCACHE_FOUND)
    set_property(GLOBAL PROPERTY RULE_LAUNCH_COMPILE ccache)
    set_property(GLOBAL PROPERTY RULE_LAUNCH_LINK ccache)
endif(CCACHE_FOUND)

set(CMAKE_BUILD_TYPE DEBUG)

SET(CMAKE_CXX_FLAGS "${CMAKE_C_FLAGS} ${CMAKE_CXX_FLAGS} -ggdb -g3 -Og")

if(DEFINED ENV{TRAVIS})
execute_process(
  COMMAND git rev-parse HEAD
  WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
  OUTPUT_VARIABLE GIT_COMMIT_HASH
  OUTPUT_STRIP_TRAILING_WHITESPACE
)
find_package(Qt5Network REQUIRED)    
add_definitions(-DGIT_COMMIT_HASH="${GIT_COMMIT_HASH}")
endif(DEFINED ENV{TRAVIS})

add_executable(KittehPlayer ${SOURCES} ${qml_QRC})

# Use the Qml/Quick modules from Qt 5.
target_link_libraries(KittehPlayer ${MPV_LIBRARIES} ${X11_LIBRARIES} ${Xext_LIBRARIES} Qt5::X11Extras)
include_directories(${Qt5Gui_PRIVATE_INCLUDE_DIRS} ${Qt5Concurrent_INCLUDE_DIRS})
qt5_use_modules(KittehPlayer Qml Quick Core Gui Widgets X11Extras)

install (TARGETS ${PROJECT_NAME} DESTINATION bin)
install (FILES "${PROJECT_NAME}.desktop" DESTINATION share/applications)
install (FILES "${PROJECT_NAME}.png" DESTINATION share/icons/hicolor/256x256/apps)

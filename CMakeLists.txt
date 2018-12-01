cmake_minimum_required(VERSION 3.5.1)

project(KittehPlayer)
include_directories(${CMAKE_SOURCE_DIR} ${CMAKE_BINARY_DIR}) 
set(CMAKE_AUTOMOC ON)


option(DEVELOP "Enable runtime QML reloading for developing." OFF)
option(DISCORD "Enable Discord SDK." OFF)


find_package(Qt5Core REQUIRED)
find_package(Qt5Gui REQUIRED)
find_package(Qt5 CONFIG REQUIRED COMPONENTS Qml Quick Gui Widgets Core X11Extras)

find_package(Qt5QuickCompiler)
if(DEVELOP)
qt5_add_resources(QT_RESOURCES qml.qrc)
else()
qtquick_compiler_add_resources(qml_QRC src/qml/qml.qrc)
endif()

find_package(PkgConfig)
pkg_check_modules(MPV REQUIRED mpv)
pkg_check_modules(X11 x11)
pkg_check_modules(Xext xext)

if(X11_FOUND AND Xext_FOUND)
add_definitions(-DENABLE_X11)
endif(X11_FOUND AND Xext_FOUND)


set(SOURCES
    src/main.cpp
    src/DirectMpvPlayerBackend.cpp
    src/utils.cpp
    src/enums.hpp
)


if(MPV_VERSION VERSION_GREATER_EQUAL "1.28.0")
set(SOURCES ${SOURCES} src/MpvPlayerBackend.cpp)
else()
add_definitions(-DDISABLE_MpvPlayerBackend)
endif(MPV_VERSION VERSION_GREATER_EQUAL "1.28.0")

find_program(CCACHE_FOUND ccache)
if(CCACHE_FOUND)
    set_property(GLOBAL PROPERTY RULE_LAUNCH_COMPILE ccache)
    set_property(GLOBAL PROPERTY RULE_LAUNCH_LINK ccache)
endif(CCACHE_FOUND)

set(CMAKE_BUILD_TYPE RELEASE)

if(TESTING OR DEFINED ENV{TRAVIS})
execute_process(
  COMMAND git rev-parse HEAD
  WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
  OUTPUT_VARIABLE GIT_COMMIT_HASH
  OUTPUT_STRIP_TRAILING_WHITESPACE
)
find_package(Qt5Network REQUIRED)    
add_definitions(-DGIT_COMMIT_HASH="${GIT_COMMIT_HASH}")
endif(TESTING OR DEFINED ENV{TRAVIS})



if(TESTING)
SET(CMAKE_C_COMPILER "/usr/bin/clang")
SET(CMAKE_CXX_COMPILER "/usr/bin/clang++")
SET(CMAKE_AR "/usr/bin/llvm-ar")
SET(CMAKE_LINKER "/usr/bin/llvm-link")
SET(CMAKE_NM "/usr/bin/llvm-nm")
SET(CMAKE_OBJDUMP "/usr/bin/llvm-objdump")
SET(CMAKE_RANLIB "/usr/bin/llvm-ranlib")
endif(TESTING)


if(DEVELOP)
set(SOURCES ${SOURCES} runtimeqml/runtimeqml.cpp)
add_definitions(-DQRC_SOURCE_PATH="${PROJECT_SOURCE_DIR}/src/qml")
add_definitions(-DQT_QML_DEBUG)
endif(DEVELOP)

if(DISCORD)
add_definitions(-DDISCORD)
execute_process(
    COMMAND git clone --depth 1 https://github.com/discordapp/discord-rpc
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
)
add_subdirectory(discord-rpc)
INCLUDE_DIRECTORIES(discord-rpc/include)
target_link_libraries(KittehPlayer discord-rpc)
endif(DISCORD)

add_executable(KittehPlayer ${SOURCES} ${qml_QRC})

# Use the Qml/Quick modules from Qt 5.
target_link_libraries(KittehPlayer ${MPV_LIBRARIES} ${X11_LIBRARIES} ${Xext_LIBRARIES} Qt5::X11Extras)
include_directories(${Qt5Gui_PRIVATE_INCLUDE_DIRS})
qt5_use_modules(KittehPlayer Qml Quick Core Gui Widgets X11Extras)

install (TARGETS ${PROJECT_NAME} DESTINATION bin)
install (FILES "${PROJECT_NAME}.desktop" DESTINATION share/applications)
install (FILES "${PROJECT_NAME}.png" DESTINATION share/icons/hicolor/256x256/apps)



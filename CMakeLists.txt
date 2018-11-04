cmake_minimum_required(VERSION 3.5.1)

project(KittehPlayer)
include_directories(${CMAKE_SOURCE_DIR} ${CMAKE_BINARY_DIR}) 
set(CMAKE_AUTOMOC ON)

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall -Werror -fstrict-aliasing -Wno-deprecated-declarations -Wno-unused-variable")

option(DEVELOP "Enable runtime QML reloading for developing." OFF)

find_package(Qt5Core REQUIRED)
find_package(Qt5Gui REQUIRED)
find_package(Qt5 REQUIRED Qml Quick Gui Widgets Core)

find_package(Qt5QuickCompiler)
qtquick_compiler_add_resources(qml_QRC src/qml/qml.qrc)

find_package(PkgConfig)
pkg_check_modules(MPV REQUIRED mpv)


include_directories(${Qt5Gui_PRIVATE_INCLUDE_DIRS}) 

set(SOURCES
	src/main.cpp
    src/MpvPlayerBackend.cpp
    src/filesavedialog.cpp
    src/fileopendialog.cpp
)

if(DEVELOP)
set(SOURCES ${SOURCES} runtimeqml/runtimeqml.cpp)
add_definitions(-DQRC_SOURCE_PATH="${PROJECT_SOURCE_DIR}/src/qml")
add_definitions(-DQT_QML_DEBUG)
endif(DEVELOP)

add_executable(KittehPlayer ${SOURCES} ${qml_QRC})

# Use the Qml/Quick modules from Qt 5.
target_link_libraries(KittehPlayer ${MPV_LIBRARIES})

qt5_use_modules(KittehPlayer Qml Quick Core Gui Widgets)

install (TARGETS ${PROJECT_NAME} DESTINATION bin)
install (FILES "${PROJECT_NAME}.desktop" DESTINATION share/applications)
install (FILES "${PROJECT_NAME}.png" DESTINATION share/icons/hicolor/256x256/apps)



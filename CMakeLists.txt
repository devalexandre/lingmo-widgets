cmake_minimum_required(VERSION 3.16)
project(lingmo-widgets LANGUAGES CXX)

set(CMAKE_INCLUDE_CURRENT_DIR ON)
set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Core Gui Qml Quick QuickControls2)

set(PROJECT_SOURCES
    src/main.cpp
    qml.qrc
)

add_executable(lingmo-widgets ${PROJECT_SOURCES})

target_link_libraries(lingmo-widgets
  PRIVATE
  Qt6::Core Qt6::Gui Qt6::Qml Qt6::Quick Qt6::QuickControls2
)

install(TARGETS lingmo-widgets RUNTIME DESTINATION bin)
install(FILES lingmo-widgets-autostart.desktop DESTINATION /etc/xdg/autostart)

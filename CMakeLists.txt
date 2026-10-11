cmake_minimum_required(VERSION 3.16)
project(lingmo-widgets LANGUAGES CXX)

set(CMAKE_INCLUDE_CURRENT_DIR ON)
set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(ECM REQUIRED NO_MODULE)
list(APPEND CMAKE_MODULE_PATH ${ECM_MODULE_PATH})

find_package(Qt6 REQUIRED COMPONENTS Core Gui Widgets Qml Quick QuickControls2 DBus)
find_package(KF6WindowSystem REQUIRED)

set(PROJECT_SOURCES
    src/main.cpp
    src/widgetsservice.cpp
    qml.qrc
)

add_executable(lingmo-widgets ${PROJECT_SOURCES})

target_link_libraries(lingmo-widgets
  PRIVATE
  Qt6::Core Qt6::Gui Qt6::Widgets Qt6::Qml Qt6::Quick Qt6::QuickControls2 Qt6::DBus
  KF6::WindowSystem
)

install(TARGETS lingmo-widgets RUNTIME DESTINATION bin)
install(FILES lingmo-widgets.desktop DESTINATION share/applications)
install(FILES lingmo-widgets-autostart.desktop DESTINATION /etc/xdg/autostart)

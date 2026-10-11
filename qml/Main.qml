import QtQuick 2.15
import QtQuick.Window 2.15
import QtCore

Window {
    visible: false

    Settings {
        id: widgetSettings
        property bool clockEnabled: true
        property bool weatherEnabled: true
        property string weatherLocation: ""
        property real weatherLatitude: 0
        property real weatherLongitude: 0
    }

    ClockWidget {
        visible: widgetSettings.clockEnabled
    }

    WeatherWidget {
        visible: widgetSettings.weatherEnabled
        locationName: widgetSettings.weatherLocation
        latitude: widgetSettings.weatherLatitude
        longitude: widgetSettings.weatherLongitude
        onConfigureRequested: centerWindow.chooseLocation()
    }
    
    // Opened from the menu/Spotlight; the session autostart (--background) shows only the widgets
    WidgetCenter {
        id: centerWindow
        visible: !startInBackground
    }

    // Status bar icon: its menu switches widgets on and off
    Connections {
        target: widgetsService
        function onShowCenterRequested() { centerWindow.open() }
        function onChooseLocationRequested() { centerWindow.chooseLocation() }
        function onWidgetToggled(name, enabled) {
            if (name === "clock")
                widgetSettings.clockEnabled = enabled
            else if (name === "weather")
                widgetSettings.weatherEnabled = enabled
        }
    }
    Connections {
        target: widgetSettings
        function onClockEnabledChanged() { widgetsService.setWidgetEnabled("clock", widgetSettings.clockEnabled) }
        function onWeatherEnabledChanged() { widgetsService.setWidgetEnabled("weather", widgetSettings.weatherEnabled) }
    }
    Component.onCompleted: {
        widgetsService.setWidgetEnabled("clock", widgetSettings.clockEnabled)
        widgetsService.setWidgetEnabled("weather", widgetSettings.weatherEnabled)
    }
}

import QtQuick 2.15
import QtQuick.Window 2.15
import QtCore

Window {
    visible: false

    Settings {
        id: widgetSettings
        property bool clockEnabled: true
        property bool weatherEnabled: true
    }

    ClockWidget {
        visible: widgetSettings.clockEnabled
    }

    WeatherWidget {
        visible: widgetSettings.weatherEnabled
    }
    
    // The control center window
    WidgetCenter {
        id: centerWindow
        // Only show center window if launched with a specific argument or explicitly requested,
        // but for now let's just show it for demonstration.
        visible: true 
    }
}

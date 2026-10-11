import QtQuick
import QtQuick.Window
import LingmoUI.CompatibleModule 3.0 as LingmoUI
import "weather.js" as Weather

OverlayCard {
    id: weatherWindow
    topOffset: 240
    visible: true

    property string locationName
    property real latitude
    property real longitude
    readonly property bool hasLocation: locationName !== ""

    // Click on the card: choose the location in the Widget Center
    signal configureRequested()

    property var current: null
    property bool failed: false

    function describe(code) {
        if (code === 0) return qsTr("Céu limpo")
        if (code <= 2) return qsTr("Parcialmente nublado")
        if (code === 3) return qsTr("Nublado")
        if (code <= 48) return qsTr("Neblina")
        if (code <= 57) return qsTr("Garoa")
        if (code <= 67) return qsTr("Chuva")
        if (code <= 77) return qsTr("Neve")
        if (code <= 82) return qsTr("Pancadas de chuva")
        if (code <= 86) return qsTr("Pancadas de neve")
        return qsTr("Tempestade")
    }

    function refresh() {
        // Not hasLocation: when the name changes, its handler runs before that
        // binding is updated, so the first city picked never loaded
        if (locationName === "")
            return
        const name = locationName
        Weather.current(latitude, longitude, function(result) {
            if (name !== weatherWindow.locationName)
                return  // location changed while loading
            // Keep the last reading on a failure, just flag it
            weatherWindow.failed = result === null
            if (result)
                weatherWindow.current = result
        })
    }

    onLocationNameChanged: {
        current = null
        failed = false
        refresh()
    }
    Component.onCompleted: refresh()

    Timer {
        interval: 30 * 60 * 1000
        running: weatherWindow.hasLocation
        repeat: true
        onTriggered: weatherWindow.refresh()
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: weatherWindow.configureRequested()
    }

    Row {
        anchors.centerIn: parent
        spacing: LingmoUI.Units.largeSpacing * 1.5

        Text {
            text: weatherWindow.current ? Weather.emoji(weatherWindow.current.code, weatherWindow.current.isDay)
                                        : "📍"
            font.pointSize: LingmoUI.Theme.fontSize * 4.5
            anchors.verticalCenter: parent.verticalCenter
        }

        Column {
            anchors.verticalCenter: parent.verticalCenter
            spacing: LingmoUI.Units.smallSpacing

            Text {
                text: !weatherWindow.hasLocation ? qsTr("Clima")
                      : weatherWindow.current ? weatherWindow.current.temperature + "°C"
                      : "--°C"
                color: LingmoUI.Theme.textColor
                font.family: LingmoUI.Theme.fontFamily
                font.pointSize: LingmoUI.Theme.fontSize * 2.6
                font.bold: true
            }

            Text {
                width: Math.min(implicitWidth, weatherWindow.width * 0.55)
                elide: Text.ElideRight
                text: {
                    if (!weatherWindow.hasLocation)
                        return qsTr("Clique para escolher o local")
                    const status = weatherWindow.current && !weatherWindow.failed
                                 ? weatherWindow.describe(weatherWindow.current.code)
                                 : weatherWindow.failed ? qsTr("Sem conexão") : qsTr("Carregando…")
                    return status + "\n" + weatherWindow.locationName
                }
                color: LingmoUI.Theme.disabledTextColor
                font.family: LingmoUI.Theme.fontFamily
                font.pointSize: LingmoUI.Theme.fontSize
            }
        }
    }
}

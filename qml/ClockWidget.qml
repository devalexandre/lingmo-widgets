import QtQuick
import QtQuick.Window
import LingmoUI.CompatibleModule 3.0 as LingmoUI

OverlayCard {
    id: clockWindow
    topOffset: 80
    visible: true

    Column {
        anchors.centerIn: parent
        spacing: LingmoUI.Units.smallSpacing

        Text {
            id: timeText
            anchors.horizontalCenter: parent.horizontalCenter
            color: LingmoUI.Theme.textColor
            font.family: LingmoUI.Theme.fontFamily
            font.pointSize: LingmoUI.Theme.fontSize * 4.5
            font.bold: true
        }

        Text {
            id: dateText
            anchors.horizontalCenter: parent.horizontalCenter
            color: LingmoUI.Theme.disabledTextColor
            font.family: LingmoUI.Theme.fontFamily
            font.pointSize: LingmoUI.Theme.fontSize * 1.3
        }
    }

    Timer {
        interval: 1000; running: true; repeat: true
        onTriggered: {
            var d = new Date()
            timeText.text = d.toLocaleTimeString(Qt.locale(), "hh:mm")
            dateText.text = d.toLocaleDateString(Qt.locale(), Locale.LongFormat)
        }
        Component.onCompleted: triggered()
    }
}

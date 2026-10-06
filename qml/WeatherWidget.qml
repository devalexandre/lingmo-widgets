import QtQuick
import QtQuick.Window
import LingmoUI.CompatibleModule 3.0 as LingmoUI

OverlayCard {
    id: weatherWindow
    y: 240
    visible: true

    Row {
        anchors.centerIn: parent
        spacing: LingmoUI.Units.largeSpacing * 1.5

        Text {
            text: "☀️"
            font.pointSize: LingmoUI.Theme.fontSize * 4.5
            anchors.verticalCenter: parent.verticalCenter
        }

        Column {
            anchors.verticalCenter: parent.verticalCenter
            spacing: LingmoUI.Units.smallSpacing

            Text {
                text: "24°C"
                color: LingmoUI.Theme.textColor
                font.family: LingmoUI.Theme.fontFamily
                font.pointSize: LingmoUI.Theme.fontSize * 2.6
                font.bold: true
            }

            Text {
                text: "Ensolarado\nRio de Janeiro"
                color: LingmoUI.Theme.disabledTextColor
                font.family: LingmoUI.Theme.fontFamily
                font.pointSize: LingmoUI.Theme.fontSize
            }
        }
    }
}

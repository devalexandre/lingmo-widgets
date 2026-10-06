import QtQuick
import QtQuick.Window
import LingmoUI.CompatibleModule 3.0 as LingmoUI

// Frameless desktop-widget window with a translucent, blurred Lingmo card
// (same tone, border and opacity as the Dock). Content goes inside.
Window {
    id: control

    default property alias content: _content.data

    width: 320
    height: 140
    x: Screen.width - width - LingmoUI.Units.largeSpacing * 3
    color: "transparent"
    flags: Qt.FramelessWindowHint | Qt.WindowStaysOnBottomHint | Qt.Tool
    // Declared inside Main.qml's hidden Window: without this Qt 6 makes that
    // hidden window our transient parent and never shows us
    transientParent: null

    LingmoUI.WindowHelper {
        id: windowHelper
    }

    LingmoUI.WindowShadow {
        view: control
        radius: _background.radius
        strength: 1
    }

    LingmoUI.WindowBlur {
        view: control
        geometry: Qt.rect(control.x, control.y, control.width, control.height)
        windowRadius: _background.radius
        enabled: control.visible
    }

    Rectangle {
        id: _background
        anchors.fill: parent
        radius: LingmoUI.Theme.hugeRadius
        color: LingmoUI.Theme.backgroundColor
        opacity: windowHelper.compositing ? (LingmoUI.Theme.darkMode ? 0.65 : 0.75) : 1.0

        Behavior on color {
            ColorAnimation {
                duration: 200
                easing.type: Easing.Linear
            }
        }
    }

    // Hairline border, like the Dock and LingmoUI.Window
    Rectangle {
        anchors.fill: parent
        radius: _background.radius
        color: "transparent"
        border.width: 1 / LingmoUI.Theme.devicePixelRatio
        border.pixelAligned: LingmoUI.Theme.devicePixelRatio > 1 ? false : true
        border.color: LingmoUI.Theme.darkMode ? Qt.rgba(1, 1, 1, 0.15) : Qt.rgba(0, 0, 0, 0.15)
        antialiasing: true
    }

    Item {
        id: _content
        anchors.fill: parent
    }
}

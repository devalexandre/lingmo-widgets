import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import LingmoUI.CompatibleModule 3.0 as LingmoUI

LingmoUI.Window {
    id: root
    width: 400
    height: 500
    minimumWidth: 400
    minimumHeight: 500
    title: qsTr("Central de Widgets")
    // Declared inside Main.qml's hidden Window: don't use it as transient parent
    transientParent: null

    // Same window look as Lingmo Settings
    background.opacity: LingmoUI.Theme.darkMode ? 0.88 : 0.97
    header.height: LingmoUI.Units.windowHeaderHeight
    contentTopMargin: 0

    LingmoUI.WindowBlur {
        view: root
        geometry: Qt.rect(root.x, root.y, root.width, root.height)
        windowRadius: root.windowRadius
        enabled: true
    }

    // One widget: emoji, name, description and its on/off switch
    component WidgetRow: LingmoUI.Card {
        id: row

        property string emoji
        property string name
        property string description
        property alias checked: toggle.checked
        signal toggled(bool checked)

        Layout.fillWidth: true
        implicitHeight: rowLayout.implicitHeight + LingmoUI.Units.largeSpacing * 2
        hoverEnabled: true

        RowLayout {
            id: rowLayout
            anchors.fill: parent
            anchors.leftMargin: LingmoUI.Units.largeSpacing * 1.5
            anchors.rightMargin: LingmoUI.Units.largeSpacing
            spacing: LingmoUI.Units.largeSpacing

            Label { text: row.emoji; font.pointSize: LingmoUI.Units.fontTitle }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2
                Label {
                    text: row.name
                    font.bold: true
                    color: LingmoUI.Theme.textColor
                }
                Label {
                    text: row.description
                    color: LingmoUI.Theme.secondaryTextColor
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                }
            }

            Switch {
                id: toggle
                onToggled: row.toggled(checked)
            }
        }
    }

    function open() {
        root.show()
        root.raise()
        root.requestActivate()
    }

    // Opens the Center with the location search (click on the weather widget)
    function chooseLocation() {
        open()
        locationPicker.open()
    }

    LocationPicker {
        id: locationPicker
        onPicked: (name, latitude, longitude) => {
            widgetSettings.weatherLatitude = latitude
            widgetSettings.weatherLongitude = longitude
            // Set last: the widget reloads when the name changes
            widgetSettings.weatherLocation = name
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.topMargin: root.header.height
        anchors.leftMargin: LingmoUI.Units.largeSpacing * 2
        anchors.rightMargin: LingmoUI.Units.largeSpacing * 2
        anchors.bottomMargin: LingmoUI.Units.largeSpacing * 2
        spacing: LingmoUI.Units.largeSpacing

        Label {
            text: qsTr("Meus Widgets")
            font.pointSize: LingmoUI.Units.fontTitle
            font.bold: true
            color: LingmoUI.Theme.textColor
            Layout.alignment: Qt.AlignHCenter
        }

        Label {
            text: qsTr("Ative ou desative os widgets da sua Área de Trabalho.")
            color: LingmoUI.Theme.secondaryTextColor
            Layout.alignment: Qt.AlignHCenter
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }

        Flickable {
            id: flick
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.topMargin: LingmoUI.Units.smallSpacing
            clip: true
            contentHeight: widgetList.implicitHeight
            boundsBehavior: Flickable.StopAtBounds

            ScrollBar.vertical: ScrollBar {}

            LingmoUI.WheelHandler {
                target: flick
            }

            ColumnLayout {
                id: widgetList
                width: flick.width
                spacing: LingmoUI.Units.smallSpacing

                WidgetRow {
                    emoji: "🕒"
                    name: qsTr("Relógio")
                    description: qsTr("Mostra a hora e a data.")
                    checked: widgetSettings.clockEnabled
                    onToggled: (checked) => widgetSettings.clockEnabled = checked
                }

                WidgetRow {
                    emoji: "☀️"
                    name: qsTr("Previsão do Tempo")
                    description: qsTr("Clima atual na sua região.")
                    checked: widgetSettings.weatherEnabled
                    onToggled: (checked) => widgetSettings.weatherEnabled = checked
                }

                // Location of the weather widget
                LingmoUI.Card {
                    Layout.fillWidth: true
                    visible: widgetSettings.weatherEnabled
                    implicitHeight: locationRow.implicitHeight + LingmoUI.Units.largeSpacing * 2

                    RowLayout {
                        id: locationRow
                        anchors.fill: parent
                        anchors.leftMargin: LingmoUI.Units.largeSpacing * 1.5
                        anchors.rightMargin: LingmoUI.Units.largeSpacing
                        spacing: LingmoUI.Units.largeSpacing

                        Label { text: "📍"; font.pointSize: LingmoUI.Units.fontSubheading }

                        Label {
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                            text: widgetSettings.weatherLocation || qsTr("Nenhum local escolhido")
                            color: widgetSettings.weatherLocation ? LingmoUI.Theme.textColor
                                                                  : LingmoUI.Theme.secondaryTextColor
                        }

                        LingmoUI.ActionButton {
                            text: widgetSettings.weatherLocation ? qsTr("Alterar") : qsTr("Escolher")
                            onClicked: locationPicker.open()
                        }
                    }
                }
            }
        }
    }
}

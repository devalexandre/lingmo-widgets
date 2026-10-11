import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import LingmoUI.CompatibleModule 3.0 as LingmoUI
import "weather.js" as Weather

// Search a city by name and pick it for the weather widget
Popup {
    id: picker

    signal picked(string name, real latitude, real longitude)

    modal: true
    focus: true
    anchors.centerIn: parent
    width: parent.width - LingmoUI.Units.largeSpacing * 4
    height: Math.min(parent.height - LingmoUI.Units.largeSpacing * 6, 380)
    padding: LingmoUI.Units.largeSpacing * 1.5

    property var results: []
    property bool searching: false
    property bool failed: false
    property int requestId: 0

    onOpened: {
        searchField.text = ""
        results = []
        failed = false
        searchField.forceActiveFocus()
    }

    function search() {
        const query = searchField.text.trim()
        const id = ++requestId
        failed = false
        if (query.length < 2) {
            results = []
            searching = false
            return
        }
        searching = true
        Weather.searchPlaces(query, Qt.locale().name.split("_")[0], function(list) {
            if (id !== picker.requestId)
                return  // a newer search is running
            picker.searching = false
            picker.failed = list === null
            picker.results = list || []
        })
    }

    Timer {
        id: debounce
        interval: 400
        onTriggered: picker.search()
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: LingmoUI.Units.largeSpacing

        Label {
            text: qsTr("Local do clima")
            font.bold: true
            font.pointSize: LingmoUI.Theme.fontSize * 1.2
            color: LingmoUI.Theme.textColor
        }

        TextField {
            id: searchField
            Layout.fillWidth: true
            placeholderText: qsTr("Buscar cidade…")
            onTextChanged: debounce.restart()
            Keys.onReturnPressed: {
                if (picker.results.length > 0)
                    list.choose(picker.results[0])
            }
        }

        ListView {
            id: list
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: LingmoUI.Units.smallSpacing / 2
            model: picker.results
            ScrollBar.vertical: ScrollBar {}

            function choose(place) {
                picker.picked(place.detail ? place.name + ", " + place.detail.split(", ")[0] : place.name,
                              place.latitude, place.longitude)
                picker.close()
            }

            delegate: Card {
                required property var modelData
                width: ListView.view.width
                implicitHeight: column.implicitHeight + LingmoUI.Units.largeSpacing
                hoverEnabled: true

                ColumnLayout {
                    id: column
                    anchors.fill: parent
                    anchors.leftMargin: LingmoUI.Units.largeSpacing
                    anchors.rightMargin: LingmoUI.Units.largeSpacing
                    spacing: 0
                    Label {
                        text: modelData.name
                        color: LingmoUI.Theme.textColor
                        Layout.fillWidth: true
                        elide: Text.ElideRight
                    }
                    Label {
                        visible: text !== ""
                        text: modelData.detail
                        color: LingmoUI.Theme.disabledTextColor
                        Layout.fillWidth: true
                        elide: Text.ElideRight
                    }
                }

                TapHandler {
                    onTapped: list.choose(modelData)
                }
            }

            Label {
                anchors.centerIn: parent
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
                color: LingmoUI.Theme.disabledTextColor
                visible: list.count === 0
                text: picker.searching ? qsTr("Buscando…")
                      : picker.failed ? qsTr("Não foi possível buscar. Confira a conexão.")
                      : searchField.text.trim().length >= 2 ? qsTr("Nenhuma cidade encontrada")
                      : qsTr("Digite o nome da cidade")
            }
        }
    }
}

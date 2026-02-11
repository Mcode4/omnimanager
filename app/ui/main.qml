import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ApplicationWindow {
    visible: true
    width: 1000
    height: 700
    title: "OmniManager"
    property bool loading: false

    header: ToolBar {
        RowLayout {
            anchors.fill: parent
            spacing: 10

            MenuBar {
                Menu {
                    title: "File"
                    MenuItem { text: "New Session" }
                    MenuItem { text: "Open" }
                    MenuSeparator {}
                    MenuItem { text: "Quit"; onTriggered: Qt.quit() }
                }

                Menu {
                    title: "Edit"
                    MenuItem { text: "Copy" }
                    MenuItem { text: "Paste" }
                }

                Menu {
                    title: "View"
                    MenuItem { text: "Toggle Sidebar" }
                    MenuItem { text: "Toogle Tabs" }
                }

                Menu {
                    title: "Terminal"
                    MenuItem { text: "Open Terminal" }
                    MenuSeparator {}
                    MenuItem { text: "Terminal Settings" }
                }
            }

            // Push Layout to Right
            Item { Layout.fillWidth: true}

            Rectangle {
                Layout.preferredWidth: 420
                height: 36
                radius: 6
                color: "#2c2c2c"
                border.color: "#444"

                RowLayout {
                    anchors.fill: parent
                    spacing: 0

                    // Category Dropdown
                    ComboBox {
                        id: categorySelector
                        model: ["All", "Files", "Apps", "Notes"]
                        currentIndex: 0
                        width: 110
                        Layout.fillHeight: true
                    }

                    Rectangle {
                        width: 1
                        color: "#444"
                        Layout.fillHeight: true
                    }

                    // Search Field
                    TextField {
                        id: commandInput
                        placeholderText: loading ? "Processing..." : "Type a command..."
                        Layout.fillWidth: true
                        background: null
                        enabled: !loading
                        color: "white"
                        onAccepted: {
                            loading = true
                            resultModel.clear()

                            let category = categorySelector.currentText.toLowerCase()
                            let query = category + " " + text

                            backend.processCommand(query)
                            text = ""
                        }
                    }  
                }
            }

            BusyIndicator {
                running: loading
                visible: loading
                Layout.alignment: Qt.AlignHCenter
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 15
        
        ListView {
            id: resultView
            Layout.fillWidth: true
            Layout.fillHeight: true
            model: resultModel

            delegate: Rectangle {
                width: ListView.view.width
                height: 40
                color: "#2c2c2c"
                radius: 6

                Text {
                    anchors.centerIn: parent
                    text: model.text
                    color: "white"
                }
            }
        }
    }

    ListModel {
        id: resultModel
    }

    Connections {
        target: backend

        function onCommandStarted() {
            loading = true
        }

        function onResultReady(resultJson) {
            var result = JSON.parse(resultJson)
            loading = false

            if (result.type === "text" || result.type === "error") {
                resultModel.append({ "text": result.message })
            }

            if (result.type === "apps") {
                resultModel.append({ "text": result.message })

                if(result.success) {
                    for(let key of Object.keys(result.data)) {
                        resultModel.append({ "text": key})
                    }
                }
            }

            if (result.type === "files") {
                resultModel.append({ "text": result.message })

                if(result.success) {
                    // console.log('RESULT DATA', result.data)
                    result.data.forEach(r => {
                        resultModel.append({ "text": r})
                    })
                }
            }
        }

    }
}

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ApplicationWindow {
    visible: true
    width: 900
    height: 600
    title: "OmniManager"

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 15

        TextField {
            id: commandInput
            placeholderText: "Type a command..."
            Layout.fillWidth: true

            onAccepted: {
                backend.processCommand(text)
                text = ""
            }
        }

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

        function onResultReady(result) {
            // console.log('CONSOLE LOG, RESULT: ', result)
            resultModel.append({ "text": result })
            // resultModel.clear()

            // for (var i = 0; i < results.length; i++) {
            //     resultModel.append({ "text": results[i] })
            // }
        }
    }
}

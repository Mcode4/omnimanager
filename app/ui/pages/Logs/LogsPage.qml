import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: logsPage
    anchors.fill: parent

    ListView {
        id: logsList
        anchors.fill: parent
        spacing: 10
        model: logModel
        clip: true

        onCountChanged: positionViewAtEnd()

        delegate: Rectangle {
            width: logsList.width - 20
            x: 10
            radius: 10
            color: "#1e1e1e"
            border.color: "#2a2a2a"
            border.width: 1
            // padding: 10

            property var colors: [
                "#9e9e9e",   // debug
                "#4da3ff",   // info
                "#e6c229",   // warning
                "#ff9933",   // error
                "#ff4d4d"    // critical
            ]

            implicitHeight: contentColumn.implicitHeight + 20

            Column {
                id: contentColumn
                spacing: 6
                width: parent.width - 20
                anchors.margins: 10
                anchors.fill: parent

                Text {
                    text: category.toUpperCase() + " • LEVEL " + level
                    font.bold: true
                    color: colors[Number(level) - 1]
                }

                Text {
                    text: message
                    wrapMode: Text.Wrap
                    color: "#dddddd"
                }
            }
        }
    }
    ListModel {id: logModel}

    Connections {
        target: backend

        function onLogSignal(level, category, message) {
            if (level && category && message) {
                logModel.append({
                    level: level,
                    category: category,
                    message: message
                })
            }
        }
    }

    Component.onCompleted: function() {
        let logs = backend.getAllLogs()
        console.log("\n\nLOGS", logs)

        if(logs) {
            logModel.clear()

            logs.forEach(l => {
                logModel.append({
                    level: l.level,
                    category: l.category,
                    message: l.message
                })
            })
        }
    }
}
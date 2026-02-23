import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs

ColumnLayout {
    id: dbSidebar
    anchors.fill: parent
    spacing: 10

    property int currentIndex: 0

    ListView {
        id: tableList
        anchors.fill: parent
        clip: true
        model: [
                "User", 
                "User Preference",
                "Conversations",
                "Messages",
                "Tasks",
                "AI State",
                "Memory",
                "Memory Links",
                "Knowledge",
                "Documents",
                "Document Chunks",
            ]

        delegate: Rectangle {
            width: tableList.width
            height: 50
            color: index === dbSidebar.currentIndex ? "#333" : "#222"

            RowLayout {
                anchors.fill: parent
                anchors.margins: 8
                spacing: 6

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        dbSidebar.currentIndex = index
                    }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: modelData
                        color: "white"
                        elide: Text.ElideRight
                    }
                }
            }
        }
    }
}
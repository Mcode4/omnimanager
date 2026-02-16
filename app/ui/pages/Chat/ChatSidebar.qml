import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ColumnLayout {
    id: root
    signal chatSelected(int chat_id)

    ListModel { id: chatModel }

    ListView {
        Layout.fillWidth: true
        Layout.fillHeight: true
        model: chatModel

        delegate: Rectangle {
            width: parent.width
            height: 50
            color: ListView.isCurrentItem ? "#333" : "#222"

            Text {
                anchors.centerIn: parent
                text: model.title
                color: "white"
                elide: Text.ElideRight
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    console.log("CLICKED:", model.id)
                    root.chatSelected(model.id)
                }
            }
        }
    }

    function loadChats() {
        chatModel.clear()
        let chats = backend.getChats()

        for(let i=0; i<chats.length; i++) {
            chatModel.append(chats[i])
        }
    }

    Component.onCompleted: loadChats()
}
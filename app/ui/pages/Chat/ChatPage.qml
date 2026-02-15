import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ColumnLayout {
    anchors.fill: parent
    spacing: 10

    property bool isLoading: false
    property int chat_id: 0

    // Chat Log
    ScrollView {
        Layout.fillWidth: true
        Layout.fillHeight: true

        TextArea {
            id: chatLog
            readOnly: true
            wrapMode: Text.Wrap
            text: ""
        }
    }

    // Loading Indicator
    Label {
        visible: isLoading
        text: "Thinking..."
        color: "gray"
    }

    // Input Row
    RowLayout {
        Layout.fillWidth: true

        TextField {
            id: inputField
            Layout.fillWidth: true
            placeholderText: "Type a message..."

            onAccepted: sendMessage()
        }

        Button {
            text: "Send"
            onClicked: sendMessage()
        }
    }

    function sendMessage() {
        let input = inputField.text.trim()
        if(input === "") return

        chatLog.text += "\n\nYou: " + inputField.text
        backend.processAIRequest(chat_id, input)

        inputField.text = ""
    }

    // Backend Connections
    Connections {
        target: backend

        function onAiStarted() {
            isLoading = true
        }

        function onAiResults(result) {
            chat_id = result.chat_id
            isLoading = false

            if(result.success) {
                chatLog.text += "\n\nAI: " + result.text
            } else {
                chatLog.text += "\n\nError: " + result.error
            }
        }
    }
}
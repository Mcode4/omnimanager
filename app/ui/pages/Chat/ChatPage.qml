import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ColumnLayout {
    anchors.fill: parent
    spacing: 10

    property bool aiStreaming: false
    property bool isThinking: false
    property bool isProcessing: false

    property int streamingIndex: -1
    property int chatId: 0

    // Chat Log
    ScrollView {
        Layout.fillWidth: true
        Layout.fillHeight: true

        ListView {
            id: messageList
            Layout.fillHeight: true
            Layout.fillWidth: true
            model: messageModel

            delegate: Text {
                width: messageList.width
                wrapMode: Text.Wrap
                text: model.role + ": " + model.content
                color: model.role === "user" ? "#00ffcc" : "#ffffff"

                // TextArea {
                //     id: chatLog
                //     readOnly: true
                //     wrapMode: Text.Wrap
                //     text: ""
                // }
            }
        }
    }

    ListModel { id: messageModel }

    // Processing Indicator
    Label {
        visible: isProcessing
        text: "Processing..."
        color: "gray"
    }

    // Loading Indicator
    Label {
        visible: isThinking
        text: "Thinking..."
        color: "lightgreen"
    }

    Item { Layout.fillHeight: true }

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

        messageModel.append({
            role: "You",
            content: inputField.text
        })

        backend.processAIRequest(chatId, input)
        inputField.text = ""
    }

    function loadMessages(id) {
        chatId = id
        messageModel.clear()
        let messages = backend.getMessages(chatId)

        for(let i=0; i<messages.length; i++) {
            messageModel.append({
                role: messages[i].role === "user" ? "You" : "Omni",
                content: messages[i].content
            })
        }
    }

    // Backend Connections
    Connections {
        target: backend

        function onAiStarted() {
            isProcessing = true
        }

        function onAiToken(phase, token) {
            isProcessing = false

            if(phase === "thinking"){
                isThinking = true
                return
            } 
            else {
                if(streamingIndex === -1){
                    messageModel.append({
                        role: "Omni",
                        content: ""
                    })
                    streamingIndex = messageModel.count - 1
                }
            }

            let current = messageModel.get(streamingIndex)
            
            messageModel.set(streamingIndex, {
                role: "Omni: ",
                content: current.content + token
            })
        }

        function onAiResults(result) {
            console.log('RESULT', result)
            isThinking = false
            isProcessing = false
            streamingIndex = -1

            if(!result.success) {
                messageModel.append({
                    role: "Omni",
                    content: "Error: " + result.error
                })
            } 

            chatId = result.chat_id
        }
    }
}
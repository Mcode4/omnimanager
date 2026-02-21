import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ColumnLayout {
    id: chatPage
    anchors.fill: parent
    spacing: 10

    property int chatId: -1
    
    property bool processing: false
    property bool thinking: false
    property bool tooling: false

    ListModel { id: messageModel }

    // Processing Indicator
    Label {
        visible: processing
        text: "⚙️ Processing..."
        color: "gray"
    }

    // Loading Indicator
    Label {
        visible: thinking
        text: "🤔 Thinking..."
        color: "gray"
    }

    Label {
        visible: tooling
        text: "🛠️ Using tools..."
        color: "gray"
    }

    // Chat Log
    ScrollView {
        Layout.fillWidth: true
        Layout.fillHeight: true

        ListView {
            id: messageList
            Layout.fillHeight: true
            Layout.fillWidth: true
            model: messageModel
            onCountChanged: messageList.positionViewAtEnd()

            delegate: Text {
                width: messageList.width
                wrapMode: Text.Wrap
                textFormat: Text.MarkdownText

                text: "**" + role + ":** " + content

                font.family: "Segoe UI, Noto Color Emoji, Arial"
                font.pixelSize: 14
            }
        }
    }

    // Item { Layout.fillHeight: true }

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

        backend.processAIRequest(chatPage.chatId, input)
        inputField.text = ""
    }

    

    function loadMessages(id) {
        chatPage.chatId = id
        console.log("LOADING ID:", id, "CHAT ID NOW:", chatPage.chatId)
        if(id === -1) {
            messageModel.clear()
            return
        }
        backend.getMessages(id)
    }

    // Backend Connections
    Connections {
        target: backend

        // Loading
        function onMessagesLoaded(messages) {
            console.log("\n\n\nLOADED MESSAGES\n\n\n")
            if(
                !messages || 
                messages.length === 0 || 
                ChatState.streamIndex(chatId) !== -1
            ) return
            messageModel.clear()
            // console.log("MESSAGE RESULTS", messages)

            messages.forEach(m => {
                // console.log("MESSAGEEEEEE", m)
                messageModel.append({
                    role: m.role === "user" ? "You" : "Omni",
                    content: m.content
                })
            })
        }

        // Phases
         function onAiStarted() {
            ChatState.setProcessing(chatPage.chatId, true)
            ChatState.setStreamTokens(chatPage.chatId, "")
            ChatState.setStreamIndex(chatPage.chatId, -1)

            console.log(`\n\n\n\n\nMODEL STARTED...\n
                PROCESSING STATE: ${ChatState.isProcessing(chatPage.chatId)}\n
                PROCESSING: ${processing}\n
            \n\n\n\n\n`)
        }
        function onModelThinking(index) {
            ChatState.setThinking(index, true)
            console.log(`\n\n\n\n\nMODEL THINKING...
                THINKING STATE: ${ChatState.isThinking(index)}
                THINKING: ${thinking}\n
            \n\n\n\n\n`)
        }
        function onModelTooling(index) {
            ChatState.setTooling(index, true)
            console.log(`\n\n\n\n\nMODEL TOOLING...
                TOOLING STATE: ${ChatState.isTooling(index)}\n
                TOOLING: ${tooling}\n
            \n\n\n\n\n`)
        }

        // Streaming and Responses
        function onAiToken(phase, token, chat_id) {
            console.log("TOKEN RECEIVED:", token, "CHAT:", chat_id)
            let existing = ChatState.streamTokens(chat_id) || ""
            let updated = existing + token
            ChatState.setStreamTokens(chat_id, updated)

            let index = ChatState.streamIndex(chat_id)

            if (chat_id !== chatPage.chatId) {
                console.log(`ERROR STREAMING: STERAMING ON ID: ${chatId} CHAT ID: ${chatPage.chatId}`)
                return
            }

            if (phase === "thinking") {
                console.log("STREAMING ERROR: PHASE: THINKING")
                return
            }

            if (index === -1) {
                console.log("INDEX === -1", index)
                messageModel.append({
                    role: "Omni",
                    content: updated
                })

                index = messageModel.count - 1
                ChatState.setStreamIndex(chat_id, index)
                console.log("INDEX SET TO LAST MODEL INDEX", index)
                return
            }

            console.log(`MESSAGES APPENDING: INDEX: ${index} CONTENT: ${updated}`)
            messageModel.set(index, {
                role: "Omni",
                content: updated
            })
        }

        function onAiResults(result) {
            ChatState.setProcessing(result.chat_id, false)
            ChatState.setThinking(result.chat_id, false)
            ChatState.setTooling(result.chat_id, false)
            console.log("\n\n\n\n\nMODEL FINISH\n")
            console.log(`PROCESSING: ${ChatState.isProcessing(result.chat_id)}, THINKING: ${ChatState.isThinking(result.chat_id)}, TOOLING: ${ChatState.isTooling(result.chat_id)}\n`)
            if(result.use_stream) {
                // ChatState.setStreamTokens(result.chat_id, "")
                // ChatState.setStreamIndex(result.chat_id, -1)
                // console.log(`USED STREAM TRUE, STREAM TOKENS: ${ChatState.streamTokens(result.chat_id)} STREAM INDEX: ${ChatState.streamIndex(result.chat_id)}\n\n\n\n\n`)
                return
            }

            if(result.success) {
                console.log("RESULTS ON FINISHED, USE STREAM:", result.use_stream)
                messageModel.append({
                        role: "Omni",
                        content: result.text
                    })
            } else {
                messageModel.append({
                    role: "Omni",
                    content: "Error: " + result.error
                })
            }
            
        }
    }
    
    Connections {
        target: ChatState

        function onStateChanged(id) {
            if (id !== chatPage.chatId)
                return

            processing = ChatState.isProcessing(id)
            thinking = ChatState.isThinking(id)
            tooling = ChatState.isTooling(id)

            console.log(`\n\n\nCHAT STATE CHANGED\n
                PROCESSING: ${processing}\n
                THINKING: ${thinking}\n
                TOOLING: ${tooling}\n
            \n\n\n`)
        }
    }

    Component.onCompleted: {
        console.log("COMPONENT COMPLETE")

        console.log("ChatState object:", ChatState)
    }
}
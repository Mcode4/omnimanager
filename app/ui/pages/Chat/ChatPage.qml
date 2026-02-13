import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

// Item {
//     ColumnLayout {
//         anchors.fill: parent
//         anchors.margins: 20

//         Label {
//             text: "AI Chat"
//             font.pixelSize: 22
//         }

//         Label {
//             text: "Chat interface coming soon..."
//             color: "#888"
//         }
//     }
// }

ApplicationWindow {
    RowLayout {
        spacing: 10

        TextField {
            text: chatTitle
        }

        ComboBox {
            id: modelSelector
            model: ["llama3", "mistral", "phi3"]
        }

        ToolButton {
            text: "⚙"
        }
    }
}
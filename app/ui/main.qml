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
        spacing: 10

        TextField {
            id: commandInput
            placeholderText: "Type a command..."
            Layout.fillWidth: true

            onAccepted: {
                backend.run_command(text)
                text = ""
            }
        }

        Button {
            text: "Test Button"
        }
    }
}

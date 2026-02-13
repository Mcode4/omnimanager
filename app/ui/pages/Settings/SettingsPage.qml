import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20

        Label {
            text: "Settings"
            font.pixelSize: 22
        }

        Label {
            text: "No settings available yet..."
            color: "#888"
        }
    }
}
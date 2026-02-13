import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20

        Label {
            text: "Notes"
            font.pixelSize: 22
        }

        Label {
            text: "No notes made yet..."
            color: "#888"
        }
    }
}
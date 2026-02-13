import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20

        Label {
            text: "Logs"
            font.pixelSize: 22
        }

        Label {
            text: "Nothing has happen so far..."
            color: "#888"
        }
    }
}
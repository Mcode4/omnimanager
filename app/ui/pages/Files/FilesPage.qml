import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20

        Label {
            text: "Apps and Files Page"
            font.pixelSize: 22
        }

        Label {
            text: "No files available..."
            color: "#888"
        }
    }
}
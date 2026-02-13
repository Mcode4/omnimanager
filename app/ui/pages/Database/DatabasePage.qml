import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20

        Label {
            text: "Database Page"
            font.pixelSize: 22
        }

        Label {
            text: "No database available..."
            color: "#888"
        }
    }
}
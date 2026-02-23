import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    anchors.fill: parent
    property var refreshTrigger: 0

    RowLayout {
        id: databaseTable
        Layout.fillWidth: true

        ListView {
            Layout.fillHeight: true
        }
    }
}
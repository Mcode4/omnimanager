import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Button {
    id: root
    property string buttonIcon: ""

    width: 50
    height: 50
    checkable: true
    checked: false

    icon.source: buttonIcon
    icon.width: 30
    icon.height: 30

    background: Rectangle {
        anchors.fill: parent
        color: root.checked ? '#c0c0c0' : "transparent"
        radius: 10
    }

    hoverEnabled: true
}
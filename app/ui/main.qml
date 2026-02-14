import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "components"

ApplicationWindow {
    visible: true
    width: 1000
    height: 600
    title: "OmniManager"

    property int currentPage: 0
    property bool sidebarVisible: true

    RowLayout {
        anchors.fill: parent

        // 1. Icon Sidebar
        Rectangle {
            id: sidebar
            width: sidebarVisible ? 60 : 0
            color: '#c0c0c0'
            Layout.fillHeight: true

            Behavior on width {
                NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
            }

            Column {
                anchors.centerIn: parent
                spacing: 10

                Repeater {
                    model: [
                        { icon: "Icons/chat.svg" },
                        { icon: "Icons/files.svg" },
                        { icon: "Icons/database.svg" },
                        { icon: "Icons/notebook.svg" },
                        { icon: "Icons/settings.svg" },
                        { icon: "Icons/logs.svg" }
                    ]

                    delegate: SidebarButton {
                        buttonIcon: modelData.icon
                        checked: currentPage === index
                        onClicked: {
                            if(currentPage === index) {
                                sidebarVisible = !sidebarVisible
                            } else {
                                currentPage = index
                                sidebarVisible = true
                            }
                        }
                    }
                }
            }
        }
        

        // 2. Sidebar Context
        Rectangle {
            id: sidebarContext
            width: sidebarVisible ? 220 : 0
            color: "#c0c0c0"
            Layout.fillHeight: true

            Behavior on width {
                NumberAnimation { duration: 200; easing.type: InOutQuad }
            }

            Loader {
                anchors.fill: parent
                source: {
                    switch (currentPage) {
                        case 0: return "pages/Chat/ChatSidebar.qml"
                        case 1: return "pages/Files/FilesSidebar.qml"
                        case 2: return "pages/Database/DatabaseSidebar.qml"
                        case 3: return "pages/Notes/NotesSidebar.qml"
                        case 4: return "pages/Settings/SettingsSidebar.qml"
                        case 5: return "pages/Logs/LogsSidebar.qml"
                    }
                }
            }
        }

        // 3. Main Content
        Loader {
                Layout.fillWidth: true
                source: {
                    switch (currentPage) {
                        case 0: return "pages/Chat/ChatPage.qml"
                        case 1: return "pages/Files/FilesPage.qml"
                        case 2: return "pages/Database/DatabasePage.qml"
                        case 3: return "pages/Notes/NotesPage.qml"
                        case 4: return "pages/Settings/SettingsPage.qml"
                        case 5: return "pages/Logs/LogsPage.qml"
                    }
                }
            }
    }
}

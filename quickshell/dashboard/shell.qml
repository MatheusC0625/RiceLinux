import Quickshell
import Quickshell.Wayland
import QtQuick
import "tabs"

PanelWindow {
    id: root
    color: "transparent"

    anchors.top: true
    implicitWidth: Screen.width
    implicitHeight: Screen.height
    margins.top: 0

    exclusionMode: "Ignore"
    exclusiveZone: 0
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "dashboard"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

    property int currentTab: 0
    readonly property var tabNames: ["Dashboard", "Media", "Performance", "Weather"]
    readonly property var tabIcons: ["󰕮", "󰝚", "󰾆", "󰖐"]

    // fecha ao clicar fora do painel
    MouseArea {
        anchors.fill: parent
        onClicked: Qt.quit()
    }
    Item {
        focus: true
        Keys.onEscapePressed: Qt.quit()
        Keys.onPressed: (event) => {
            if (event.key === Qt.Key_1) root.currentTab = 0
            else if (event.key === Qt.Key_2) root.currentTab = 1
            else if (event.key === Qt.Key_3) root.currentTab = 2
            else if (event.key === Qt.Key_4) root.currentTab = 3
            else return
            event.accepted = true
        }
    }

    Rectangle {
        id: panel
        width: 400
        height: Screen.height - 64
        x: Screen.width
        y: 44
        radius: 18
        color: "#282828"
        border.width: 1
        border.color: "#504945"

        Behavior on x {
            SpringAnimation { spring: 3.5; damping: 0.45; mass: 0.9 }
        }

        Component.onCompleted: x = Screen.width - width - 16

        MouseArea {
            anchors.fill: parent
            onClicked: {} // absorve clique, não fecha o painel
        }

        Column {
            anchors.fill: parent
            anchors.margins: 18
            spacing: 16

            // barra de abas
            Row {
                id: tabBar
                width: parent.width
                height: 36
                spacing: 6

                Repeater {
                    model: root.tabNames.length
                    delegate: Rectangle {
                        required property int index
                        width: (tabBar.width - tabBar.spacing * (root.tabNames.length - 1)) / root.tabNames.length
                        height: 36
                        radius: 10
                        color: root.currentTab === index ? "#3c3836" : "transparent"

                        Row {
                            anchors.centerIn: parent
                            spacing: 6
                            Text {
                                text: root.tabIcons[index]
                                color: root.currentTab === index ? "#f9f5d7" : "#a89984"
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 15
                            }
                            Text {
                                text: root.tabNames[index]
                                visible: root.currentTab === index
                                color: "#f9f5d7"
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 12
                                font.bold: true
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: root.currentTab = index
                        }
                    }
                }
            }

            Rectangle {
                width: parent.width
                height: 1
                color: "#3c3836"
            }

            // conteúdo da aba ativa
            Item {
                width: parent.width
                height: parent.height - tabBar.height - 16 - 1

                DashboardTab {
                    anchors.fill: parent
                    visible: root.currentTab === 0
                }
                MediaTab {
                    anchors.fill: parent
                    visible: root.currentTab === 1
                    active: root.currentTab === 1
                }
                PerformanceTab {
                    anchors.fill: parent
                    visible: root.currentTab === 2
                    active: root.currentTab === 2
                }
                WeatherTab {
                    anchors.fill: parent
                    visible: root.currentTab === 3
                    active: root.currentTab === 3
                }
            }
        }
    }
}

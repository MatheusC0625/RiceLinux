import Quickshell
import Quickshell.Io
import QtQuick

Item {
    id: root
    property bool active: true

    readonly property string scriptsDir: Quickshell.shellDir + "/scripts"
    property var weather: null

    function dayLabel(dateStr, index) {
        if (index === 0) return "Hoje"
        const d = new Date(dateStr)
        return Qt.formatDate(d, "ddd")
    }

    Process {
        id: weatherProc
        command: ["bash", root.scriptsDir + "/weather.sh"]
        stdout: StdioCollector {
            onStreamFinished: {
                try { root.weather = JSON.parse(text) } catch (e) {}
            }
        }
    }

    Timer {
        interval: 900000
        running: root.active
        repeat: true
        triggeredOnStart: true
        onTriggered: weatherProc.running = true
    }

    Column {
        anchors.fill: parent
        spacing: 12
        visible: root.weather !== null

        Rectangle {
            width: parent.width
            height: 220
            radius: 14
            color: "#3c3836"
            Column {
                anchors.fill: parent
                anchors.margins: 18
                spacing: 8

                Text {
                    text: root.weather ? root.weather.location : ""
                    color: "#f9f5d7"; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 19; font.bold: true
                }
                Text {
                    text: root.weather ? root.weather.region : ""
                    color: "#a89984"; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 12
                }
                Row {
                    spacing: 10
                    topPadding: 4
                    Text { text: "󰖨"; color: "#f9f5d7"; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 40 }
                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        Text {
                            text: root.weather ? (root.weather.tempC + "°C") : ""
                            color: "#f9f5d7"; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 30; font.bold: true
                        }
                        Text {
                            text: root.weather ? root.weather.desc : ""
                            color: "#a89984"; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 13
                        }
                    }
                }
                Rectangle { width: parent.width; height: 1; color: "#282828"; }
                Row {
                    spacing: 8
                    Text { text: "󰖜"; color: "#ebdbb2"; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 13 }
                    Text {
                        text: "Nascer " + (root.weather ? root.weather.sunrise : "") + "   󰖛  Pôr " + (root.weather ? root.weather.sunset : "")
                        color: "#ebdbb2"; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 12
                    }
                }
                Row {
                    spacing: 8
                    Text { text: "󰖎"; color: "#ebdbb2"; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 13 }
                    Text {
                        text: "Umidade " + (root.weather ? root.weather.humidity : "") + "%   󰈐  Sensação " + (root.weather ? root.weather.feelsLikeC : "") + "°C"
                        color: "#ebdbb2"; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 12
                    }
                }
            }
        }

        Rectangle {
            width: parent.width
            height: parent.height - 220 - 12
            radius: 14
            color: "#3c3836"

            Column {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 10

                Repeater {
                    model: root.weather ? root.weather.days : []
                    delegate: Rectangle {
                        required property var modelData
                        required property int index
                        width: parent.width
                        height: 64
                        radius: 10
                        color: "#282828"
                        Item {
                            anchors.fill: parent
                            anchors.margins: 12

                            Text {
                                id: dayLbl
                                anchors.left: parent.left
                                anchors.verticalCenter: parent.verticalCenter
                                text: root.dayLabel(modelData.date, index)
                                width: 56
                                color: "#f9f5d7"; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 13; font.bold: true
                            }
                            Text {
                                id: dayIcon
                                anchors.left: dayLbl.right
                                anchors.verticalCenter: parent.verticalCenter
                                text: "󰖐"
                                color: "#ebdbb2"; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 20
                            }
                            Text {
                                anchors.left: dayIcon.right
                                anchors.leftMargin: 10
                                anchors.right: dayTemp.left
                                anchors.rightMargin: 10
                                anchors.verticalCenter: parent.verticalCenter
                                text: modelData.desc
                                elide: Text.ElideRight
                                color: "#a89984"; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 11
                            }
                            Text {
                                id: dayTemp
                                anchors.right: parent.right
                                anchors.verticalCenter: parent.verticalCenter
                                text: modelData.max + "°/" + modelData.min + "°"
                                color: "#ebdbb2"; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 12
                            }
                        }
                    }
                }
            }
        }
    }

    Text {
        visible: root.weather === null
        anchors.centerIn: parent
        text: "Carregando clima…"
        color: "#a89984"
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: 14
    }
}

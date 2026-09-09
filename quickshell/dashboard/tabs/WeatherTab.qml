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
            height: 150
            radius: 14
            color: "#3c3836"
            Row {
                anchors.fill: parent
                anchors.margins: 20

                Column {
                    width: parent.width * 0.55
                    height: parent.height
                    spacing: 4
                    Text {
                        text: root.weather ? root.weather.location : ""
                        color: "#f9f5d7"; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 20; font.bold: true
                    }
                    Text {
                        text: root.weather ? root.weather.region : ""
                        color: "#a89984"; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 12
                    }
                    Item { width: 1; height: 10 }
                    Row {
                        spacing: 10
                        Text { text: "󰖨"; color: "#f9f5d7"; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 44 }
                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            Text {
                                text: root.weather ? (root.weather.tempC + "°C") : ""
                                color: "#f9f5d7"; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 34; font.bold: true
                            }
                            Text {
                                text: root.weather ? root.weather.desc : ""
                                color: "#a89984"; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 13
                            }
                        }
                    }
                }

                Column {
                    width: parent.width * 0.45
                    height: parent.height
                    spacing: 10
                    Row {
                        spacing: 8
                        Text { text: "󰖜"; color: "#ebdbb2"; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 14 }
                        Text {
                            text: "Nascer do sol " + (root.weather ? root.weather.sunrise : "")
                            color: "#ebdbb2"; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 12
                        }
                    }
                    Row {
                        spacing: 8
                        Text { text: "󰖛"; color: "#ebdbb2"; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 14 }
                        Text {
                            text: "Pôr do sol " + (root.weather ? root.weather.sunset : "")
                            color: "#ebdbb2"; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 12
                        }
                    }
                    Row {
                        spacing: 8
                        Text { text: "󰖎"; color: "#ebdbb2"; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 14 }
                        Text {
                            text: "Umidade " + (root.weather ? root.weather.humidity : "") + "%"
                            color: "#ebdbb2"; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 12
                        }
                    }
                    Row {
                        spacing: 8
                        Text { text: "󰈐"; color: "#ebdbb2"; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 14 }
                        Text {
                            text: "Sensação " + (root.weather ? root.weather.feelsLikeC : "") + "°C  ·  vento " + (root.weather ? root.weather.windKmph : "") + " km/h"
                            color: "#ebdbb2"; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 12
                        }
                    }
                }
            }
        }

        Rectangle {
            width: parent.width
            height: parent.height - 150 - 12
            radius: 14
            color: "#3c3836"

            Row {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 10

                Repeater {
                    model: root.weather ? root.weather.days : []
                    delegate: Rectangle {
                        required property var modelData
                        required property int index
                        width: (parent.width - 20) / 3
                        height: parent.height
                        radius: 10
                        color: "#282828"
                        Column {
                            anchors.centerIn: parent
                            spacing: 8
                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: root.dayLabel(modelData.date, index)
                                color: "#f9f5d7"; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 13; font.bold: true
                            }
                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: "󰖐"
                                color: "#ebdbb2"; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 26
                            }
                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: modelData.max + "° / " + modelData.min + "°"
                                color: "#a89984"; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 12
                            }
                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                width: parent.parent.width - 12
                                horizontalAlignment: Text.AlignHCenter
                                text: modelData.desc
                                color: "#a89984"; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 10
                                wrapMode: Text.WordWrap
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

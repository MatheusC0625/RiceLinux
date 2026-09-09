import Quickshell
import Quickshell.Io
import QtQuick

Item {
    id: root
    property bool active: true

    readonly property string scriptsDir: Quickshell.shellDir + "/scripts"
    property var stats: null

    function fmtRate(bps) {
        if (bps > 1024 * 1024) return (bps / (1024 * 1024)).toFixed(1) + " MB/s"
        if (bps > 1024) return (bps / 1024).toFixed(1) + " KB/s"
        return bps.toFixed(0) + " B/s"
    }

    Process {
        id: sysProc
        command: ["bash", root.scriptsDir + "/sysinfo.sh"]
        stdout: StdioCollector {
            onStreamFinished: {
                try { root.stats = JSON.parse(text) } catch (e) {}
                pollTimer.running = root.active
            }
        }
    }

    Timer {
        id: pollTimer
        interval: 1600
        running: root.active
        repeat: false
        onTriggered: sysProc.running = true
    }
    onActiveChanged: if (active && !sysProc.running) sysProc.running = true

    Column {
        anchors.fill: parent
        spacing: 12

        Row {
            width: parent.width
            height: 120
            spacing: 12

            Rectangle {
                width: (parent.width - 12) / 2
                height: parent.height
                radius: 12
                color: "#3c3836"
                Column {
                    anchors.fill: parent
                    anchors.margins: 18
                    spacing: 8
                    Row {
                        spacing: 8
                        Text { text: "󰻠"; color: "#f9f5d7"; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 16 }
                        Text {
                            text: root.stats ? root.stats.cpu.model : "CPU"
                            color: "#ebdbb2"; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 11
                            width: parent.parent.width - 30; elide: Text.ElideRight
                        }
                    }
                    Text {
                        text: (root.stats ? root.stats.cpu.usage : 0) + "%"
                        color: "#f9f5d7"; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 26; font.bold: true
                    }
                    Text {
                        text: (root.stats ? root.stats.cpu.tempC : 0) + "°C"
                        color: "#a89984"; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 12
                    }
                }
            }

            Rectangle {
                width: (parent.width - 12) / 2
                height: parent.height
                radius: 12
                color: "#3c3836"
                Column {
                    anchors.fill: parent
                    anchors.margins: 18
                    spacing: 8
                    Row {
                        spacing: 8
                        Text { text: "󰢮"; color: "#f9f5d7"; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 16 }
                        Text {
                            text: root.stats ? root.stats.gpu.model : "GPU"
                            color: "#ebdbb2"; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 11
                            width: parent.parent.width - 30; elide: Text.ElideRight
                        }
                    }
                    Text {
                        text: (root.stats ? root.stats.gpu.usage : 0) + "%"
                        color: "#f9f5d7"; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 26; font.bold: true
                    }
                    Text {
                        text: (root.stats ? root.stats.gpu.tempC : 0) + "°C"
                        color: "#a89984"; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 12
                    }
                }
            }
        }

        Row {
            width: parent.width
            height: parent.height - 120 - 12
            spacing: 12

            Rectangle {
                width: (parent.width - 24) / 3
                height: parent.height
                radius: 12
                color: "#3c3836"
                Column {
                    anchors.centerIn: parent
                    spacing: 10
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "󰍛  Memória"
                        color: "#ebdbb2"; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 12
                    }
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: root.stats ? Math.round(root.stats.mem.usedGiB / root.stats.mem.totalGiB * 100) + "%" : "--%"
                        color: "#f9f5d7"; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 30; font.bold: true
                    }
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: root.stats ? (root.stats.mem.usedGiB + " / " + root.stats.mem.totalGiB + " GiB") : ""
                        color: "#a89984"; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 11
                    }
                }
            }

            Rectangle {
                width: (parent.width - 24) / 3
                height: parent.height
                radius: 12
                color: "#3c3836"
                Column {
                    anchors.centerIn: parent
                    spacing: 10
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "󰋊  Armazenamento"
                        color: "#ebdbb2"; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 12
                    }
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: root.stats ? Math.round(root.stats.disk.usedGiB / root.stats.disk.totalGiB * 100) + "%" : "--%"
                        color: "#f9f5d7"; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 30; font.bold: true
                    }
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: root.stats ? (root.stats.disk.usedGiB + " / " + root.stats.disk.totalGiB + " GiB") : ""
                        color: "#a89984"; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 11
                    }
                }
            }

            Rectangle {
                width: (parent.width - 24) / 3
                height: parent.height
                radius: 12
                color: "#3c3836"
                Column {
                    anchors.centerIn: parent
                    spacing: 10
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "󰛳  Rede"
                        color: "#ebdbb2"; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 12
                    }
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "↓ " + (root.stats ? root.fmtRate(root.stats.net.rxBps) : "--")
                        color: "#f9f5d7"; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 14
                    }
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "↑ " + (root.stats ? root.fmtRate(root.stats.net.txBps) : "--")
                        color: "#a89984"; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 14
                    }
                }
            }
        }
    }
}

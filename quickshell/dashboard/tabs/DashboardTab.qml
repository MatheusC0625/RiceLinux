import Quickshell
import Quickshell.Io
import QtQuick

Item {
    id: root
    property bool active: true

    readonly property string scriptsDir: Quickshell.shellDir + "/scripts"
    readonly property string cacheDir: "/home/matheus/.cache/quickshell/dashboard"

    property var host: null
    property var weather: null
    property var track: null
    property string artPath: ""
    property string lastArtUrl: ""
    property real volume: 0
    property real brightness: 0

    function fmtDate() {
        const d = new Date()
        return Qt.formatDate(d, "dddd, d 'de' MMMM")
    }

    Process {
        id: hostProc
        command: ["bash", root.scriptsDir + "/hostinfo.sh"]
        stdout: StdioCollector {
            onStreamFinished: {
                try { root.host = JSON.parse(text) } catch (e) {}
            }
        }
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

    readonly property string sep: "\u001f"
    Process {
        id: mediaProc
        command: ["playerctl", "-a", "metadata", "--format",
            "{{status}}" + root.sep + "{{title}}" + root.sep + "{{artist}}" + root.sep + "{{mpris:artUrl}}"]
        stdout: StdioCollector {
            onStreamFinished: {
                const lines = text.split("\n").filter(l => l.length > 0)
                let chosen = null
                for (const line of lines) {
                    const p = line.split(root.sep)
                    if (p.length < 4) continue
                    if (p[0] === "Playing") { chosen = p; break }
                    if (!chosen) chosen = p
                }
                if (!chosen) { root.track = null; return }
                root.track = { status: chosen[0], title: chosen[1], artist: chosen[2], art: chosen[3] }
                if (root.track.art && root.track.art !== root.lastArtUrl) {
                    root.lastArtUrl = root.track.art
                    artProc.command = ["bash", root.scriptsDir + "/../../music-popup/circle_art.sh", root.track.art, root.cacheDir]
                    artProc.running = true
                }
            }
        }
    }
    Process {
        id: artProc
        stdout: StdioCollector {
            onStreamFinished: { const p = text.trim(); if (p.length > 0) root.artPath = p }
        }
    }

    Process {
        id: volProc
        command: ["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"]
        stdout: StdioCollector {
            onStreamFinished: { const m = text.match(/[\d.]+/); if (m) root.volume = parseFloat(m[0]) }
        }
    }
    Process {
        id: brightProc
        command: ["brightnessctl", "-m"]
        stdout: StdioCollector {
            onStreamFinished: {
                const parts = text.trim().split(",")
                if (parts.length >= 4) {
                    const pct = parseInt(parts[3].replace("%", ""))
                    if (!isNaN(pct)) root.brightness = pct / 100
                }
            }
        }
    }

    function setVolume(fraction) {
        const pct = Math.max(0, Math.min(100, Math.round(fraction * 100)))
        Quickshell.execDetached(["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", pct + "%"])
        root.volume = fraction
    }
    function setBrightness(fraction) {
        const pct = Math.max(1, Math.min(100, Math.round(fraction * 100)))
        Quickshell.execDetached(["brightnessctl", "set", pct + "%"])
        root.brightness = fraction
    }

    Timer {
        interval: 1000
        running: root.active
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            mediaProc.running = true
            volProc.running = true
            brightProc.running = true
        }
    }
    Timer {
        interval: 600000
        running: root.active
        repeat: true
        triggeredOnStart: true
        onTriggered: weatherProc.running = true
    }
    Component.onCompleted: hostProc.running = true

    Column {
        anchors.fill: parent
        spacing: 12

        Rectangle {
            width: parent.width
            height: 90
            radius: 12
            color: "#3c3836"
            Row {
                anchors.fill: parent
                anchors.margins: 14
                spacing: 14
                Text {
                    text: "󰖐"
                    color: "#f9f5d7"
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 32
                    anchors.verticalCenter: parent.verticalCenter
                }
                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 2
                    Text {
                        text: root.weather ? (root.weather.tempC + "°C") : "--°C"
                        color: "#f9f5d7"
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 22
                        font.bold: true
                    }
                    Text {
                        text: root.weather ? (root.weather.desc + " · " + root.weather.location) : "carregando…"
                        color: "#a89984"
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 12
                    }
                }
            }
        }

        Rectangle {
            width: parent.width
            height: 90
            radius: 12
            color: "#3c3836"
            Column {
                anchors.fill: parent
                anchors.margins: 14
                spacing: 6
                Text {
                    text: root.fmtDate()
                    color: "#f9f5d7"
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 14
                    font.bold: true
                }
                Text {
                    text: root.host ? ("󰣇  " + root.host.distro) : ""
                    color: "#a89984"
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 12
                }
                Text {
                    text: root.host ? ("󰇄  " + root.host.wm + "  ·  up " + root.host.uptime) : ""
                    color: "#a89984"
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 12
                }
            }
        }

        Rectangle {
            width: parent.width
            height: 100
            radius: 12
            color: "#3c3836"
            Item {
                anchors.fill: parent
                anchors.margins: 16
                visible: root.track !== null

                Item {
                    id: miniArt
                    width: 68
                    height: 68
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    rotation: 0

                    Rectangle {
                        anchors.fill: parent
                        radius: width / 2
                        color: "#282828"
                        visible: miniImg.status !== Image.Ready
                    }
                    Image {
                        id: miniImg
                        anchors.fill: parent
                        fillMode: Image.PreserveAspectFit
                        asynchronous: true
                        cache: false
                        source: root.artPath ? ("file://" + root.artPath) : ""
                    }
                    NumberAnimation {
                        running: root.track && root.track.status === "Playing"
                        target: miniArt
                        property: "rotation"
                        from: miniArt.rotation
                        to: miniArt.rotation + 360
                        duration: 6000
                        loops: Animation.Infinite
                    }
                }

                Column {
                    anchors.left: miniArt.right
                    anchors.leftMargin: 14
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 3
                    Text {
                        width: parent.width
                        text: root.track ? root.track.title : ""
                        color: "#f9f5d7"
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 13
                        font.bold: true
                        elide: Text.ElideRight
                    }
                    Text {
                        width: parent.width
                        text: root.track ? root.track.artist : ""
                        color: "#a89984"
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 11
                        elide: Text.ElideRight
                    }
                }
            }
            Text {
                visible: root.track === null
                anchors.centerIn: parent
                text: "Nada tocando"
                color: "#a89984"
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 12
            }
        }

        // sliders verticais de volume/brilho
        Rectangle {
            width: parent.width
            height: 240
            radius: 12
            color: "#3c3836"

            Row {
                anchors.centerIn: parent
                spacing: 40

                Column {
                    spacing: 10
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "󰕾"
                        color: "#ebdbb2"
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 16
                    }
                    Rectangle {
                        id: volTrack
                        width: 14
                        height: 160
                        radius: 7
                        color: "#282828"
                        anchors.horizontalCenter: parent.horizontalCenter

                        Rectangle {
                            anchors.bottom: parent.bottom
                            width: parent.width
                            height: parent.height * root.volume
                            radius: 7
                            color: "#f9f5d7"
                        }
                        MouseArea {
                            anchors.fill: parent
                            anchors.margins: -8
                            onPositionChanged: (m) => { if (pressed) root.setVolume(1 - Math.max(0, Math.min(1, m.y / height))) }
                            onClicked: (m) => root.setVolume(1 - Math.max(0, Math.min(1, m.y / height)))
                        }
                    }
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: Math.round(root.volume * 100) + "%"
                        color: "#a89984"
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 10
                    }
                }

                Column {
                    spacing: 10
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "󰃟"
                        color: "#ebdbb2"
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 16
                    }
                    Rectangle {
                        id: brightTrack
                        width: 14
                        height: 160
                        radius: 7
                        color: "#282828"
                        anchors.horizontalCenter: parent.horizontalCenter

                        Rectangle {
                            anchors.bottom: parent.bottom
                            width: parent.width
                            height: parent.height * root.brightness
                            radius: 7
                            color: "#ebdbb2"
                        }
                        MouseArea {
                            anchors.fill: parent
                            anchors.margins: -8
                            onPositionChanged: (m) => { if (pressed) root.setBrightness(1 - Math.max(0, Math.min(1, m.y / height))) }
                            onClicked: (m) => root.setBrightness(1 - Math.max(0, Math.min(1, m.y / height)))
                        }
                    }
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: Math.round(root.brightness * 100) + "%"
                        color: "#a89984"
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 10
                    }
                }
            }
        }
    }
}

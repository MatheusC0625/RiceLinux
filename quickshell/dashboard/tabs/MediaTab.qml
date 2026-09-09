import Quickshell
import Quickshell.Io
import QtQuick

Item {
    id: root
    property bool active: true

    readonly property string cacheDir: "/home/matheus/.cache/quickshell/dashboard"
    readonly property string artScript: "/home/matheus/.config/quickshell/music-popup/circle_art.sh"

    property var track: null
    property string artPath: ""
    property string lastArtUrl: ""

    function control(action) {
        if (!track) return
        Quickshell.execDetached(["playerctl", "-p", track.player, action])
    }
    function seekTo(fraction) {
        if (!track || !track.length) return
        const seconds = (fraction * track.length) / 1000000
        Quickshell.execDetached(["playerctl", "-p", track.player, "position", seconds.toFixed(1)])
    }
    function fmtTime(us) {
        const s = Math.max(0, Math.floor(us / 1000000))
        const m = Math.floor(s / 60)
        const r = s % 60
        return m + ":" + (r < 10 ? "0" : "") + r
    }
    function updateArt() {
        if (!track || !track.art) { root.artPath = ""; root.lastArtUrl = ""; return }
        if (track.art === root.lastArtUrl) return
        root.lastArtUrl = track.art
        artProc.command = ["bash", root.artScript, track.art, root.cacheDir]
        artProc.running = true
    }

    readonly property string sep: "\u001f"

    Process {
        id: metaProc
        command: ["playerctl", "-a", "metadata", "--format",
            "{{status}}" + root.sep + "{{playerName}}" + root.sep + "{{title}}" + root.sep +
            "{{artist}}" + root.sep + "{{mpris:artUrl}}" + root.sep + "{{position}}" + root.sep + "{{mpris:length}}"]
        stdout: StdioCollector {
            onStreamFinished: {
                const lines = text.split("\n").filter(l => l.length > 0)
                let chosen = null
                for (const line of lines) {
                    const p = line.split(root.sep)
                    if (p.length < 7) continue
                    if (p[0] === "Playing") { chosen = p; break }
                    if (!chosen) chosen = p
                }
                if (!chosen) { root.track = null; return }
                root.track = {
                    status: chosen[0], player: chosen[1], title: chosen[2], artist: chosen[3],
                    art: chosen[4], position: parseFloat(chosen[5]) || 0, length: parseFloat(chosen[6]) || 0
                }
                root.updateArt()
            }
        }
    }
    Process {
        id: artProc
        stdout: StdioCollector {
            onStreamFinished: { const p = text.trim(); if (p.length > 0) root.artPath = p }
        }
    }

    Timer {
        interval: 1000
        running: root.active
        repeat: true
        triggeredOnStart: true
        onTriggered: metaProc.running = true
    }

    Item {
        anchors.fill: parent
        visible: root.track !== null

        Item {
            id: art
            width: 200
            height: 200
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 10
            rotation: 0

            Rectangle {
                anchors.fill: parent
                radius: width / 2
                color: "#3c3836"
                visible: cdImage.status !== Image.Ready
            }
            Image {
                id: cdImage
                anchors.fill: parent
                fillMode: Image.PreserveAspectFit
                asynchronous: true
                cache: false
                smooth: true
                source: root.artPath ? ("file://" + root.artPath) : ""
            }

            NumberAnimation {
                running: root.track && root.track.status === "Playing"
                target: art
                property: "rotation"
                from: art.rotation
                to: art.rotation + 360
                duration: 8000
                loops: Animation.Infinite
            }
        }

        Text {
            id: titleText
            anchors.top: art.bottom
            anchors.topMargin: 18
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.track ? root.track.title : ""
            color: "#f9f5d7"
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 18
            font.bold: true
        }
        Text {
            id: artistText
            anchors.top: titleText.bottom
            anchors.topMargin: 4
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.track ? root.track.artist : ""
            color: "#a89984"
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 13
        }

        Row {
            id: controls
            anchors.top: artistText.bottom
            anchors.topMargin: 18
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 26

            Text {
                text: "󰒮"
                color: "#ebdbb2"
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 26
                MouseArea { anchors.fill: parent; anchors.margins: -8; onClicked: root.control("previous") }
            }
            Text {
                text: root.track && root.track.status === "Playing" ? "󰏤" : "󰐊"
                color: "#f9f5d7"
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 26
                MouseArea { anchors.fill: parent; anchors.margins: -8; onClicked: root.control("play-pause") }
            }
            Text {
                text: "󰒭"
                color: "#ebdbb2"
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 26
                MouseArea { anchors.fill: parent; anchors.margins: -8; onClicked: root.control("next") }
            }
        }

        Item {
            anchors.top: controls.bottom
            anchors.topMargin: 18
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: 60
            anchors.rightMargin: 60
            height: 26

            Text {
                text: root.track ? root.fmtTime(root.track.position) : "0:00"
                color: "#a89984"
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 11
                anchors.left: parent.left
                anchors.top: parent.top
            }
            Text {
                text: root.track ? root.fmtTime(root.track.length) : "0:00"
                color: "#a89984"
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 11
                anchors.right: parent.right
                anchors.top: parent.top
            }
            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.topMargin: 16
                height: 5
                radius: 2.5
                color: "#3c3836"

                Rectangle {
                    height: parent.height
                    radius: 2.5
                    color: "#f9f5d7"
                    width: parent.width * (root.track && root.track.length ? Math.min(1, root.track.position / root.track.length) : 0)
                }
                MouseArea {
                    anchors.fill: parent
                    anchors.margins: -6
                    onClicked: (m) => root.seekTo(Math.max(0, Math.min(1, m.x / width)))
                }
            }
        }
    }

    Text {
        visible: root.track === null
        anchors.centerIn: parent
        text: "Nada tocando no momento"
        color: "#a89984"
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: 14
    }
}

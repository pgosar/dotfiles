import QtQuick
import QtQuick.Layouts

RowLayout {
    id: musicPlayerRoot
    Layout.preferredWidth: 320
    Layout.fillHeight: true
    spacing: 12

    // Properties
    property var activePlayer
    property var colors

    // Cover art container
    Rectangle {
        width: 54
        height: 54
        radius: 8
        color: colors.surface
        clip: true

        Image {
            anchors.fill: parent
            source: (musicPlayerRoot.activePlayer && musicPlayerRoot.activePlayer.trackArtUrl) ? musicPlayerRoot.activePlayer.trackArtUrl : ""
            fillMode: Image.PreserveAspectCrop
            visible: source != ""
        }

        // Fallback Music Icon if no album art URL
        Text {
            text: "󰎆"
            color: colors.purple
            anchors.centerIn: parent
            font {
                family: "JetBrainsMono Nerd Font"
                pixelSize: 24
            }
            visible: !(musicPlayerRoot.activePlayer && musicPlayerRoot.activePlayer.trackArtUrl)
        }
    }

    // Info & Controls
    ColumnLayout {
        Layout.fillWidth: true
        spacing: 2

        Text {
            text: musicPlayerRoot.activePlayer ? musicPlayerRoot.activePlayer.trackTitle : "No Media Playing"
            color: colors.text
            font {
                family: "JetBrainsMono Nerd Font"
                pixelSize: 13
                bold: true
            }
            Layout.fillWidth: true
            elide: Text.ElideRight
        }

        Text {
            text: musicPlayerRoot.activePlayer ? musicPlayerRoot.activePlayer.trackArtist : ""
            color: colors.muted
            font {
                family: "JetBrainsMono Nerd Font"
                pixelSize: 11
            }
            Layout.fillWidth: true
            elide: Text.ElideRight
        }

        RowLayout {
            spacing: 14
            visible: musicPlayerRoot.activePlayer !== null

            Text {
                text: "󰒮"
                color: colors.text
                font.pixelSize: 16
                MouseArea {
                    anchors.fill: parent
                    onClicked: musicPlayerRoot.activePlayer.previous()
                }
            }

            Text {
                text: (musicPlayerRoot.activePlayer && musicPlayerRoot.activePlayer.isPlaying) ? "󰏤" : "󰐊"
                color: colors.purple
                font.pixelSize: 18
                MouseArea {
                    anchors.fill: parent
                    onClicked: musicPlayerRoot.activePlayer.togglePlaying()
                }
            }

            Text {
                text: "󰒭"
                color: colors.text
                font.pixelSize: 16
                MouseArea {
                    anchors.fill: parent
                    onClicked: musicPlayerRoot.activePlayer.next()
                }
            }
        }
    }
}

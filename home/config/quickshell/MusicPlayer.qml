import QtQuick
import QtQuick.Layouts

ColumnLayout {
    id: musicPlayerRoot
    spacing: 6
    Layout.alignment: Qt.AlignHCenter

    // Properties
    property var activePlayer
    property var colors

    // Cover art container (Centered)
    Rectangle {
        width: 48
        height: 48
        radius: 8
        color: colors.surface
        clip: true
        Layout.alignment: Qt.AlignHCenter

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
                pixelSize: 22
            }
            visible: !(musicPlayerRoot.activePlayer && musicPlayerRoot.activePlayer.trackArtUrl)
        }
    }

    // Metadata & Controls (Centered)
    Text {
        text: musicPlayerRoot.activePlayer ? musicPlayerRoot.activePlayer.trackTitle : "No Media Playing"
        color: colors.text
        horizontalAlignment: Text.AlignHCenter
        font {
            family: "JetBrainsMono Nerd Font"
            pixelSize: 12
            bold: true
        }
        Layout.alignment: Qt.AlignHCenter
        Layout.maximumWidth: 400
        elide: Text.ElideRight
    }

    Text {
        text: musicPlayerRoot.activePlayer ? musicPlayerRoot.activePlayer.trackArtist : ""
        color: colors.muted
        horizontalAlignment: Text.AlignHCenter
        font {
            family: "JetBrainsMono Nerd Font"
            pixelSize: 10
        }
        Layout.alignment: Qt.AlignHCenter
        Layout.maximumWidth: 400
        elide: Text.ElideRight
    }

    RowLayout {
        spacing: 16
        Layout.alignment: Qt.AlignHCenter
        visible: musicPlayerRoot.activePlayer !== null

        // Previous button
        Text {
            text: "󰒮"
            color: colors.text
            font.pixelSize: 15
            MouseArea {
                anchors.fill: parent
                onClicked: musicPlayerRoot.activePlayer.previous()
            }
        }

        // Play/Pause button
        Text {
            text: (musicPlayerRoot.activePlayer && musicPlayerRoot.activePlayer.isPlaying) ? "󰏤" : "󰐊"
            color: colors.purple
            font.pixelSize: 17
            MouseArea {
                anchors.fill: parent
                onClicked: musicPlayerRoot.activePlayer.togglePlaying()
            }
        }

        // Next button
        Text {
            text: "󰒭"
            color: colors.text
            font.pixelSize: 15
            MouseArea {
                anchors.fill: parent
                onClicked: musicPlayerRoot.activePlayer.next()
            }
        }
    }
}

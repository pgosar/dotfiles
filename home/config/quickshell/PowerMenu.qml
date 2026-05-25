import QtQuick
import QtQuick.Layouts
import Quickshell.Io

ColumnLayout {
    id: powerMenuContainer
    spacing: 8
    Layout.alignment: Qt.AlignHCenter
    
    // Properties
    property var colors
    property bool expanded: false

    // Slide-out Suspend Button
    Text {
        text: "󰏤"
        color: colors.yellow
        visible: powerMenuContainer.expanded
        opacity: powerMenuContainer.expanded ? 1.0 : 0.0
        scale: powerMenuContainer.expanded ? 1.0 : 0.0
        Layout.alignment: Qt.AlignHCenter
        font {
            family: "JetBrainsMono Nerd Font"
            pixelSize: 20
            bold: true
        }
        Behavior on opacity { NumberAnimation { duration: 150 } }
        Behavior on scale { NumberAnimation { duration: 150 } }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                powerMenuContainer.expanded = false;
                suspendProc.running = true;
            }
        }
    }

    // Slide-out Reboot Button
    Text {
        text: "󰜉"
        color: colors.light_peach || colors.yellow
        visible: powerMenuContainer.expanded
        opacity: powerMenuContainer.expanded ? 1.0 : 0.0
        scale: powerMenuContainer.expanded ? 1.0 : 0.0
        Layout.alignment: Qt.AlignHCenter
        font {
            family: "JetBrainsMono Nerd Font"
            pixelSize: 20
            bold: true
        }
        Behavior on opacity { NumberAnimation { duration: 150 } }
        Behavior on scale { NumberAnimation { duration: 150 } }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                powerMenuContainer.expanded = false;
                rebootProc.running = true;
            }
        }
    }

    // Slide-out Shutdown Button
    Text {
        text: "󰐥"
        color: colors.red
        visible: powerMenuContainer.expanded
        opacity: powerMenuContainer.expanded ? 1.0 : 0.0
        scale: powerMenuContainer.expanded ? 1.0 : 0.0
        Layout.alignment: Qt.AlignHCenter
        font {
            family: "JetBrainsMono Nerd Font"
            pixelSize: 20
            bold: true
        }
        Behavior on opacity { NumberAnimation { duration: 150 } }
        Behavior on scale { NumberAnimation { duration: 150 } }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                powerMenuContainer.expanded = false;
                shutdownProc.running = true;
            }
        }
    }

    // Main Power Toggle Button
    Text {
        text: ""
        color: colors.red
        Layout.alignment: Qt.AlignHCenter
        font {
            family: "JetBrainsMono Nerd Font"
            pixelSize: 22
            bold: true
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                powerMenuContainer.expanded = !powerMenuContainer.expanded;
            }
        }
    }

    // Native processes for power actions
    Process {
        id: shutdownProc
        command: ["systemctl", "poweroff"]
    }

    Process {
        id: rebootProc
        command: ["systemctl", "reboot"]
    }

    Process {
        id: suspendProc
        command: ["systemctl", "suspend"]
    }
}

import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Services.SystemTray
import Quickshell.Bluetooth
import Quickshell.Networking
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

PanelWindow {
    id: leftBarWindow
    
    // Properties
    required property var modelData
    screen: modelData

    required property var colors
    required property string activeSsid
    required property string connectedDeviceNames


    anchors {
        left: true
        top: true
        bottom: true
    }
    implicitWidth: 60
    exclusiveZone: 60
    exclusionMode: PanelWindow.ExclusionMode.Normal

    // Background
    Rectangle {
        anchors.fill: parent
        color: colors.base
        opacity: 0.90
        border.color: colors.purple
        border.width: 1.5
        radius: 12
        anchors.margins: 4
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 16

        // Operating System / Arch Logo
        Text {
            text: ""
            color: colors.blue
            Layout.alignment: Qt.AlignHCenter
            font {
                family: "JetBrainsMono Nerd Font"
                pixelSize: 22
                bold: true
            }
        }

        // Workspaces List
        ColumnLayout {
            id: workspacesCol
            spacing: 12
            Layout.alignment: Qt.AlignHCenter

            Repeater {
                model: 5 // Display workspaces 1-5
                delegate: Text {
                    property var ws: Hyprland.workspaces.values.find(w => w.id === (index + 1))
                    property bool isActive: Hyprland.focusedWorkspace?.id === (index + 1)

                    text: isActive ? "󰮯" : "󰊠"
                    color: isActive ? colors.peach : (ws ? colors.blue : colors.muted)
                    Layout.alignment: Qt.AlignHCenter
                    font {
                        family: "JetBrainsMono Nerd Font"
                        pixelSize: 18
                        bold: true
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: Hyprland.dispatch("workspace " + (index + 1))
                    }
                }
            }
        }

        // Spacer
        Item {
            Layout.fillHeight: true
        }

        // System Tray (Status Notifier Items)
        // Wrapped in standard Column instead of ColumnLayout, with strict width/height to prevent stretching
        Column {
            spacing: 10
            width: parent.width
            Layout.alignment: Qt.AlignHCenter

            Repeater {
                model: SystemTray.items
                delegate: Item {
                    // Force a bounding box of 18x18 for each icon
                    width: 18
                    height: 18
                    anchors.horizontalCenter: parent.horizontalCenter

                    Image {
                        anchors.fill: parent
                        source: modelData.icon
                        fillMode: Image.PreserveAspectFit

                        MouseArea {
                            anchors.fill: parent
                            acceptedButtons: Qt.LeftButton | Qt.RightButton
                            onClicked: (mouse) => {
                                if (mouse.button === Qt.RightButton) {
                                    if (modelData.hasMenu) {
                                        modelData.display(leftBarWindow, mouse.x, mouse.y);
                                    }
                                } else {
                                    modelData.activate();
                                }
                            }
                        }
                    }
                }
            }
        }

        // Custom Wi-Fi Widget
        Text {
            text: {
                if (!Networking.wifiEnabled) return "󰖪";
                return leftBarWindow.activeSsid ? "󰖩" : "󰤮";
            }
            color: Networking.wifiEnabled && leftBarWindow.activeSsid ? colors.cyan : colors.muted
            Layout.alignment: Qt.AlignHCenter
            font {
                family: "JetBrainsMono Nerd Font"
                pixelSize: 20
                bold: true
            }

            ToolTip.visible: wifiHover.containsMouse
            ToolTip.text: {
                if (!Networking.wifiEnabled) return "Wi-Fi Disabled";
                return leftBarWindow.activeSsid ? "Wi-Fi Connected to: " + leftBarWindow.activeSsid : "Wi-Fi Disconnected";
            }

            MouseArea {
                id: wifiHover
                anchors.fill: parent
                hoverEnabled: true
                onClicked: {
                    Networking.wifiEnabled = !Networking.wifiEnabled;
                }
            }
        }

        // Custom Bluetooth Widget
        Text {
            text: (Bluetooth.defaultAdapter && Bluetooth.defaultAdapter.enabled) ? "" : "󰂲"
            color: (Bluetooth.defaultAdapter && Bluetooth.defaultAdapter.enabled) ? colors.blue : colors.muted
            Layout.alignment: Qt.AlignHCenter
            font {
                family: "JetBrainsMono Nerd Font"
                pixelSize: 20
                bold: true
            }

            ToolTip.visible: btHover.containsMouse
            ToolTip.text: {
                if (!Bluetooth.defaultAdapter || !Bluetooth.defaultAdapter.enabled) return "Bluetooth Disabled";
                return leftBarWindow.connectedDeviceNames ? "Bluetooth Connected to: " + leftBarWindow.connectedDeviceNames : "Bluetooth Enabled";
            }

            MouseArea {
                id: btHover
                anchors.fill: parent
                hoverEnabled: true
                onClicked: {
                    if (Bluetooth.defaultAdapter) {
                        Bluetooth.defaultAdapter.enabled = !Bluetooth.defaultAdapter.enabled;
                    }
                }
            }
        }

        // Custom Power Menu Widget
        PowerMenu {
            colors: leftBarWindow.colors
        }
    }
}

import Quickshell
import Quickshell.Wayland
import Quickshell.Bluetooth
import Quickshell.Networking
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

PanelWindow {
    id: flyoutWindow

    // Properties passed from root
    required property var modelData
    screen: modelData

    required property var colors
    required property bool wifiSettingsOpen
    required property bool btSettingsOpen

    anchors {
        left: true
        top: true
        bottom: true
    }
    margins {
        left: 60
        top: 10
        bottom: 10
    }
    implicitWidth: 300
    exclusiveZone: 0
    exclusionMode: PanelWindow.ExclusionMode.Ignore

    // Only show if one of the settings panel is toggled
    visible: wifiSettingsOpen || btSettingsOpen

    // Background Container
    Rectangle {
        anchors.fill: parent
        color: colors.base
        opacity: 0.96
        border.color: colors.purple
        border.width: 1.5
        radius: 12
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 14
        spacing: 12

        // Header Section
        RowLayout {
            Layout.fillWidth: true

            Text {
                text: wifiSettingsOpen ? "Wi-Fi Networks" : "Bluetooth Devices"
                color: colors.text
                font {
                    family: "JetBrainsMono Nerd Font"
                    pixelSize: 16
                    bold: true
                }
                Layout.fillWidth: true
            }

            // Close Button
            Text {
                text: "󰅖"
                color: colors.red
                font {
                    family: "JetBrainsMono Nerd Font"
                    pixelSize: 18
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        root.wifiSettingsOpen = false;
                        root.btSettingsOpen = false;
                    }
                }
            }
        }

        // Divider
        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: colors.muted
            opacity: 0.4
        }

        // 1. WI-FI SECTION
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: wifiSettingsOpen
            spacing: 10

            // Wi-Fi Toggle Row
            RowLayout {
                Layout.fillWidth: true

                Text {
                    text: Networking.wifiEnabled ? "Wi-Fi Radio Enabled" : "Wi-Fi Radio Disabled"
                    color: colors.text
                    font {
                        family: "JetBrainsMono Nerd Font"
                        pixelSize: 13
                        bold: true
                    }
                    Layout.fillWidth: true
                }

                Switch {
                    checked: Networking.wifiEnabled
                    onCheckedChanged: {
                        if (checked !== Networking.wifiEnabled) {
                            Networking.wifiEnabled = checked;
                        }
                    }
                }
            }

            // Networks List Scroll Container
            ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true

                Column {
                    id: networksList
                    width: 272
                    spacing: 10

                    Text {
                        text: "Scanning for networks..."
                        color: colors.muted
                        font.family: "JetBrainsMono Nerd Font"
                        visible: Networking.wifiEnabled && (!root.wifiDevice || root.wifiDevice.networks.values.length === 0)
                    }

                    Text {
                        text: "Wi-Fi is turned off."
                        color: colors.muted
                        font.family: "JetBrainsMono Nerd Font"
                        visible: !Networking.wifiEnabled
                    }

                    Repeater {
                        id: networksRepeater
                        model: (Networking.wifiEnabled && root.wifiDevice) ? root.wifiDevice.networks.values : []
                        
                        property int activePskIndex: -1

                        delegate: Column {
                            width: parent.width
                            spacing: 6

                            RowLayout {
                                width: parent.width
                                spacing: 8

                                // Signal Strength Icon
                                Text {
                                    text: {
                                        var strength = modelData.signalStrength;
                                        if (strength > 75) return "󰤨";
                                        if (strength > 50) return "󰤥";
                                        if (strength > 25) return "󰤢";
                                        return "󰤟";
                                    }
                                    color: modelData.connected ? colors.cyan : colors.text
                                    font {
                                        family: "JetBrainsMono Nerd Font"
                                        pixelSize: 16
                                    }
                                }

                                // SSID
                                Text {
                                    text: modelData.name || "Unknown Network"
                                    color: modelData.connected ? colors.cyan : colors.text
                                    font {
                                        family: "JetBrainsMono Nerd Font"
                                        pixelSize: 13
                                        bold: modelData.connected
                                    }
                                    Layout.fillWidth: true
                                    elide: Text.ElideRight
                                }

                                // State text
                                Text {
                                    text: modelData.connected ? "Connected" : (modelData.stateChanging ? "Connecting..." : "")
                                    color: colors.muted
                                    font {
                                        family: "JetBrainsMono Nerd Font"
                                        pixelSize: 11
                                    }
                                }
                            }

                            // Password Entry Flyout
                            RowLayout {
                                width: parent.width
                                visible: !modelData.connected && !modelData.known && (networksRepeater.activePskIndex === index)
                                spacing: 8

                                TextField {
                                    id: pskField
                                    placeholderText: "Password..."
                                    echoMode: TextInput.Password
                                    color: colors.text
                                    font.family: "JetBrainsMono Nerd Font"
                                    Layout.fillWidth: true
                                    background: Rectangle {
                                        color: colors.surface
                                        border.color: colors.muted
                                        border.width: 1
                                        radius: 6
                                    }
                                }

                                Button {
                                    text: "Connect"
                                    contentItem: Text {
                                        text: "Connect"
                                        color: colors.base
                                        font {
                                            family: "JetBrainsMono Nerd Font"
                                            bold: true
                                            pixelSize: 12
                                        }
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                    background: Rectangle {
                                        color: colors.purple
                                        radius: 6
                                    }
                                    onClicked: {
                                        modelData.connectWithPsk(pskField.text);
                                        networksRepeater.activePskIndex = -1;
                                    }
                                }
                            }

                            // Interactive Area for SSID row
                            MouseArea {
                                height: 24
                                width: parent.width
                                z: 1
                                onClicked: {
                                    if (modelData.connected) {
                                        modelData.disconnect();
                                    } else if (modelData.known) {
                                        modelData.connect();
                                    } else {
                                        networksRepeater.activePskIndex = (networksRepeater.activePskIndex === index) ? -1 : index;
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        // 2. BLUETOOTH SECTION
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: btSettingsOpen
            spacing: 10

            // Bluetooth Toggle Row
            RowLayout {
                Layout.fillWidth: true

                Text {
                    text: (Bluetooth.defaultAdapter && Bluetooth.defaultAdapter.enabled) ? "Bluetooth Enabled" : "Bluetooth Disabled"
                    color: colors.text
                    font {
                        family: "JetBrainsMono Nerd Font"
                        pixelSize: 13
                        bold: true
                    }
                    Layout.fillWidth: true
                }

                Switch {
                    checked: Bluetooth.defaultAdapter && Bluetooth.defaultAdapter.enabled
                    onCheckedChanged: {
                        if (Bluetooth.defaultAdapter && checked !== Bluetooth.defaultAdapter.enabled) {
                            Bluetooth.defaultAdapter.enabled = checked;
                        }
                    }
                }
            }

            // Bluetooth Devices Scroll Container
            ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true

                Column {
                    id: btList
                    width: 272
                    spacing: 10

                    Text {
                        text: "No paired Bluetooth devices."
                        color: colors.muted
                        font.family: "JetBrainsMono Nerd Font"
                        visible: Bluetooth.defaultAdapter && Bluetooth.defaultAdapter.enabled && Bluetooth.devices.values.length === 0
                    }

                    Text {
                        text: "Bluetooth is turned off."
                        color: colors.muted
                        font.family: "JetBrainsMono Nerd Font"
                        visible: !Bluetooth.defaultAdapter || !Bluetooth.defaultAdapter.enabled
                    }

                    Repeater {
                        model: (Bluetooth.defaultAdapter && Bluetooth.defaultAdapter.enabled) ? Bluetooth.devices.values : []
                        delegate: RowLayout {
                            width: 272
                            spacing: 8

                            Text {
                                text: modelData.connected ? "󰂱" : "󰂲"
                                color: modelData.connected ? colors.blue : colors.text
                                font {
                                    family: "JetBrainsMono Nerd Font"
                                    pixelSize: 16
                                }
                            }

                            ColumnLayout {
                                spacing: 1
                                Layout.fillWidth: true

                                Text {
                                    text: modelData.name || "Unknown Device"
                                    color: modelData.connected ? colors.blue : colors.text
                                    font {
                                        family: "JetBrainsMono Nerd Font"
                                        pixelSize: 13
                                        bold: modelData.connected
                                    }
                                    Layout.fillWidth: true
                                    elide: Text.ElideRight
                                }

                                Text {
                                    text: {
                                        var stateStr = modelData.connected ? "Connected" : "Disconnected";
                                        if (modelData.batteryAvailable) {
                                            stateStr += " • Battery: " + Math.round(modelData.battery) + "%";
                                        }
                                        return stateStr;
                                    }
                                    color: colors.muted
                                    font {
                                        family: "JetBrainsMono Nerd Font"
                                        pixelSize: 10
                                    }
                                    Layout.fillWidth: true
                                }
                            }

                            // Interactive Area for Bluetooth row
                            MouseArea {
                                Layout.fillWidth: true
                                height: 32
                                onClicked: {
                                    if (modelData.connected) {
                                        modelData.disconnect();
                                    } else {
                                        modelData.connect();
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

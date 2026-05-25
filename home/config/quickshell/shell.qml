import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Services.SystemTray
import Quickshell.Services.Mpris
import Quickshell.Bluetooth
import Quickshell.Networking
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls


ShellRoot {
    id: root

    // Instantiate generated colors
    Colors {
        id: colors
    }

    // Weather state variables (fetched natively via XMLHttpRequest)
    property string weatherCity: "San Francisco"
    property string weatherTemp: "--"
    property string weatherDesc: "Loading..."
    property string weatherIcon: "󰖐"

    function updateWeather() {
        var xhrIp = new XMLHttpRequest();
        xhrIp.open("GET", "https://ipinfo.io/ip");
        xhrIp.onreadystatechange = function() {
            if (xhrIp.readyState === XMLHttpRequest.DONE && xhrIp.status === 200) {
                var ip = xhrIp.responseText.trim();
                var xhrLoc = new XMLHttpRequest();
                xhrLoc.open("GET", "https://ipinfo.io/" + ip + "/json");
                xhrLoc.onreadystatechange = function() {
                    if (xhrLoc.readyState === XMLHttpRequest.DONE && xhrLoc.status === 200) {
                        var loc = JSON.parse(xhrLoc.responseText);
                        var city = loc.city || "";
                        var region = loc.region || "";
                        var locEscaped = (city + "+" + region).replace(/ /g, "+");
                        var xhrWttr = new XMLHttpRequest();
                        xhrWttr.open("GET", "https://wttr.in/" + locEscaped + "?format=j1");
                        xhrWttr.onreadystatechange = function() {
                            if (xhrWttr.readyState === XMLHttpRequest.DONE && xhrWttr.status === 200) {
                                try {
                                    var weather = JSON.parse(xhrWttr.responseText);
                                    var cond = weather.current_condition[0];
                                    root.weatherCity = city;
                                    root.weatherTemp = cond.temp_F;
                                    var desc = cond.weatherDesc[0].value;
                                    root.weatherDesc = desc;
                                    
                                    // Map descriptions to Nerd Font weather icons
                                    var descLower = desc.toLowerCase();
                                    if (descLower.includes("sunny") || descLower.includes("clear")) {
                                        root.weatherIcon = "󰖙";
                                    } else if (descLower.includes("rain") || descLower.includes("drizzle") || descLower.includes("shower")) {
                                        root.weatherIcon = "󰖗";
                                    } else if (descLower.includes("snow") || descLower.includes("sleet") || descLower.includes("hail")) {
                                        root.weatherIcon = "󰼶";
                                    } else if (descLower.includes("thunder")) {
                                        root.weatherIcon = "󰙖";
                                    } else {
                                        root.weatherIcon = "󰖐"; // cloudy/misty/default
                                    }
                                } catch (e) {
                                    console.log("Failed to parse weather JSON:", e);
                                }
                            }
                        };
                        xhrWttr.send();
                    }
                };
                xhrLoc.send();
            }
        };
        xhrIp.send();
    }

    // Fetch weather on startup and every 15 minutes
    Timer {
        interval: 900000 // 15 mins
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.updateWeather()
    }

    // active player mapping
    property var activePlayer: Mpris.players.values.length > 0 ? Mpris.players.values[0] : null

    // wifi variables
    property var wifiDevice: Networking.devices.values.find(d => d.type === DeviceType.Wifi)
    property string activeSsid: {
        if (!wifiDevice) return "";
        var activeNet = wifiDevice.networks.values.find(n => n.connected);
        return activeNet ? activeNet.name : "";
    }

    // bluetooth variables
    property var connectedDevices: Bluetooth.devices.values.filter(d => d.connected)
    property string connectedDeviceNames: connectedDevices.map(d => d.name).join(", ")

    // 1. LEFT PANEL WINDOW
    Variants {
        model: Quickshell.screens
        delegate: Component {
            PanelWindow {
                required property var modelData
                screen: modelData
                
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
                    ColumnLayout {
                        spacing: 10
                        Layout.alignment: Qt.AlignHCenter

                        Repeater {
                            model: SystemTray.items
                            delegate: Image {
                                width: 22
                                height: 22
                                source: modelData.icon
                                fillMode: Image.PreserveAspectFit
                                Layout.alignment: Qt.AlignHCenter

                                MouseArea {
                                    anchors.fill: parent
                                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                                    onClicked: (mouse) => {
                                        if (mouse.button === Qt.RightButton) {
                                            if (modelData.hasMenu) {
                                                modelData.display(parent, mouse.x, mouse.y);
                                            }
                                        } else {
                                            modelData.activate();
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
                            return root.activeSsid ? "󰖩" : "󰤮";
                        }
                        color: Networking.wifiEnabled && root.activeSsid ? colors.cyan : colors.muted
                        Layout.alignment: Qt.AlignHCenter
                        font {
                            family: "JetBrainsMono Nerd Font"
                            pixelSize: 20
                            bold: true
                        }

                        ToolTip.visible: wifiHover.containsMouse
                        ToolTip.text: {
                            if (!Networking.wifiEnabled) return "Wi-Fi Disabled";
                            return root.activeSsid ? "Wi-Fi Connected to: " + root.activeSsid : "Wi-Fi Disconnected";
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
                            return root.connectedDeviceNames ? "Bluetooth Connected to: " + root.connectedDeviceNames : "Bluetooth Enabled";
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

                    // Power Menu Widget (Vertical Expanding/Sliding)
                    ColumnLayout {
                        id: powerMenuContainer
                        spacing: 8
                        Layout.alignment: Qt.AlignHCenter
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
                            color: colors.orange || colors.light_peach
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
                    }
                }
            }
        }
    }

    // 2. TOP EXPANDABLE POPUP WINDOW
    Variants {
        model: Quickshell.screens
        delegate: Component {
            PanelWindow {
                required property var modelData
                screen: modelData

                id: topBar
                anchors {
                    top: true
                    left: true
                    right: true
                }
                margins {
                    left: 60
                }
                
                property bool expanded: false
                
                // Collapsed state is 6px height. Expanded is 90px.
                implicitHeight: expanded ? 90 : 6
                exclusiveZone: 0
                exclusionMode: PanelWindow.ExclusionMode.Ignore

                Behavior on implicitHeight {
                    NumberAnimation {
                        duration: 300
                        easing.type: Easing.OutQuint
                    }
                }

                // Dynamic background: pastel trim that expands
                Rectangle {
                    anchors.fill: parent
                    color: colors.base
                    opacity: topBar.expanded ? 0.92 : 1.0
                    border.color: colors.purple
                    border.width: topBar.expanded ? 1.5 : 3.0
                    radius: topBar.expanded ? 12 : 0
                    anchors.margins: topBar.expanded ? 4 : 0
                    
                    Behavior on opacity { NumberAnimation { duration: 200 } }
                    Behavior on radius { NumberAnimation { duration: 200 } }
                }

                // Main Content container (visible only when expanded)
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 14
                    spacing: 20
                    opacity: topBar.expanded ? 1.0 : 0.0
                    visible: topBar.expanded

                    Behavior on opacity {
                        NumberAnimation { duration: 200 }
                    }

                    // 2.1 MUSIC PLAYER WIDGET
                    RowLayout {
                        Layout.preferredWidth: 320
                        Layout.fillHeight: true
                        spacing: 12

                        // Cover art container
                        Rectangle {
                            width: 54
                            height: 54
                            radius: 8
                            color: colors.surface
                            clip: true

                            Image {
                                anchors.fill: parent
                                source: (root.activePlayer && root.activePlayer.trackArtUrl) ? root.activePlayer.trackArtUrl : ""
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
                                visible: !(root.activePlayer && root.activePlayer.trackArtUrl)
                            }
                        }

                        // Info & Controls
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2

                            Text {
                                text: root.activePlayer ? root.activePlayer.trackTitle : "No Media Playing"
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
                                text: root.activePlayer ? root.activePlayer.trackArtist : ""
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
                                visible: root.activePlayer !== null

                                Text {
                                    text: "󰒮"
                                    color: colors.text
                                    font.pixelSize: 16
                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: root.activePlayer.previous()
                                    }
                                }

                                Text {
                                    text: (root.activePlayer && root.activePlayer.isPlaying) ? "󰏤" : "󰐊"
                                    color: colors.purple
                                    font.pixelSize: 18
                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: root.activePlayer.togglePlaying()
                                    }
                                }

                                Text {
                                    text: "󰒭"
                                    color: colors.text
                                    font.pixelSize: 16
                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: root.activePlayer.next()
                                    }
                                }
                            }
                        }
                    }

                    // Spacer
                    Item {
                        Layout.fillWidth: true
                    }

                    // 2.2 DATE & TIME WIDGET
                    ColumnLayout {
                        Layout.alignment: Qt.AlignHCenter
                        spacing: 2

                        Text {
                            id: timeDisplay
                            text: Qt.formatDateTime(new Date(), "hh:mm:ss AP")
                            color: colors.yellow
                            Layout.alignment: Qt.AlignHCenter
                            font {
                                family: "JetBrainsMono Nerd Font"
                                pixelSize: 20
                                bold: true
                            }

                            Timer {
                                interval: 1000
                                running: true
                                repeat: true
                                onTriggered: timeDisplay.text = Qt.formatDateTime(new Date(), "hh:mm:ss AP")
                            }
                        }

                        Text {
                            id: dateDisplay
                            text: Qt.formatDateTime(new Date(), "dddd, MMMM dd, yyyy")
                            color: colors.text
                            Layout.alignment: Qt.AlignHCenter
                            font {
                                family: "JetBrainsMono Nerd Font"
                                pixelSize: 12
                                bold: true
                            }
                            
                            Timer {
                                interval: 60000
                                running: true
                                repeat: true
                                onTriggered: dateDisplay.text = Qt.formatDateTime(new Date(), "dddd, MMMM dd, yyyy")
                            }
                        }
                    }

                    // Spacer
                    Item {
                        Layout.fillWidth: true
                    }

                    // 2.3 WEATHER WIDGET
                    RowLayout {
                        Layout.preferredWidth: 320
                        Layout.alignment: Qt.AlignRight
                        spacing: 12

                        Text {
                            text: root.weatherIcon
                            color: colors.rose
                            font {
                                family: "JetBrainsMono Nerd Font"
                                pixelSize: 32
                            }
                        }

                        ColumnLayout {
                            spacing: 2

                            Text {
                                text: root.weatherTemp + "°F"
                                color: colors.rose
                                font {
                                    family: "JetBrainsMono Nerd Font"
                                    pixelSize: 18
                                    bold: true
                                }
                            }

                            Text {
                                text: root.weatherCity + " • " + root.weatherDesc
                                color: colors.muted
                                font {
                                    family: "JetBrainsMono Nerd Font"
                                    pixelSize: 11
                                }
                                Layout.preferredWidth: 200
                                elide: Text.ElideRight
                            }
                        }
                    }
                }

                // Hover trigger MouseArea with expansion logic and exit delay
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: {
                        collapseTimer.stop();
                        topBar.expanded = true;
                    }
                    onExited: {
                        collapseTimer.restart();
                    }
                }

                Timer {
                    id: collapseTimer
                    interval: 400
                    running: false
                    repeat: false
                    onTriggered: topBar.expanded = false
                }
            }
        }
    }

    // 3. Native command runners
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

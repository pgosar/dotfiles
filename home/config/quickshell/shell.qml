import Quickshell
import Quickshell.Services.Mpris
import Quickshell.Bluetooth
import Quickshell.Networking
import QtQuick

ShellRoot {
    id: root

    // Instantiate generated colors
    Colors {
        id: themeColors
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

    // quick settings state
    property bool wifiSettingsOpen: false
    property bool btSettingsOpen: false

    // 1. LEFT PANEL WINDOWS
    Variants {
        model: Quickshell.screens
        delegate: Component {
            LeftBar {
                modelData: modelData
                colors: themeColors
                activeSsid: root.activeSsid
                connectedDeviceNames: root.connectedDeviceNames
            }
        }
    }

    // 2. QUICK SETTINGS FLYOUT WINDOWS
    Variants {
        model: Quickshell.screens
        delegate: Component {
            QuickSettingsFlyout {
                modelData: modelData
                colors: themeColors
                wifiSettingsOpen: root.wifiSettingsOpen
                btSettingsOpen: root.btSettingsOpen
            }
        }
    }

    // 3. TOP PANEL WINDOWS
    Variants {
        model: Quickshell.screens
        delegate: Component {
            TopBar {
                modelData: modelData
                colors: themeColors
                activePlayer: root.activePlayer
                weatherCity: root.weatherCity
                weatherTemp: root.weatherTemp
                weatherDesc: root.weatherDesc
                weatherIcon: root.weatherIcon
            }
        }
    }
}


/* Auto-generated quickshell colors */
import QtQuick

QtObject {
    property color base: "#211b1c"
    property color mantle: "#191415"
    property color surface: "#2f2728"
    property color text: "#b2b9b8"
    property color muted: "#707574"
    property color white: "#b2b9b8"
    property color red: "#82adc9"
    property color green: "#c98282"
    property color yellow: "#cc8f7e"
    property color blue: "#c99282"
    property color purple: "#c99982"
    property color cyan: "#e79872"
    property color rose: "#82adc9"
    property color light_green: "#c98282"
    property color light_peach: "#cc8f7e"
    property color light_blue: "#c99282"
    property color light_purple: "#c99982"
    property color light_cyan: "#e79872"
    property color peach: "#b2b9b8"

    function reload() {
        var xhr = new XMLHttpRequest();
        xhr.open("GET", "file:///home/chilly/code/dotfiles/home/scripts/theme.json?t=" + Date.now());
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE && xhr.status === 200) {
                try {
                    var c = JSON.parse(xhr.responseText);
                    if (c.base !== undefined) base = c.base;
                    if (c.mantle !== undefined) mantle = c.mantle;
                    if (c.surface !== undefined) surface = c.surface;
                    if (c.text !== undefined) text = c.text;
                    if (c.muted !== undefined) muted = c.muted;
                    if (c.white !== undefined) white = c.white;
                    if (c.red !== undefined) red = c.red;
                    if (c.green !== undefined) green = c.green;
                    if (c.yellow !== undefined) yellow = c.yellow;
                    if (c.blue !== undefined) blue = c.blue;
                    if (c.purple !== undefined) purple = c.purple;
                    if (c.cyan !== undefined) cyan = c.cyan;
                    if (c.rose !== undefined) rose = c.rose;
                    if (c.light_green !== undefined) light_green = c.light_green;
                    if (c.light_peach !== undefined) light_peach = c.light_peach;
                    if (c.light_blue !== undefined) light_blue = c.light_blue;
                    if (c.light_purple !== undefined) light_purple = c.light_purple;
                    if (c.light_cyan !== undefined) light_cyan = c.light_cyan;
                    if (c.peach !== undefined) peach = c.peach;
                } catch (e) {
                    console.log("Failed to parse theme.json:", e);
                }
            }
        };
        xhr.send();
    }
}

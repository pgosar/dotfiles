import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts

PanelWindow {
    id: topBarWindow
    
    // Properties
    required property var modelData
    screen: modelData

    required property var colors
    required property var activePlayer
    required property string weatherCity
    required property string weatherTemp
    required property string weatherDesc
    required property string weatherIcon


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
        opacity: topBarWindow.expanded ? 0.92 : 1.0
        border.color: colors.purple
        border.width: topBarWindow.expanded ? 1.5 : 3.0
        radius: topBarWindow.expanded ? 12 : 0
        anchors.margins: topBarWindow.expanded ? 4 : 0
        
        Behavior on opacity { NumberAnimation { duration: 200 } }
        Behavior on radius { NumberAnimation { duration: 200 } }
    }

    // Main Content container (visible only when expanded)
    RowLayout {
        anchors.fill: parent
        anchors.margins: 14
        spacing: 20
        opacity: topBarWindow.expanded ? 1.0 : 0.0
        visible: topBarWindow.expanded

        Behavior on opacity {
            NumberAnimation { duration: 200 }
        }

        // 2.1 MUSIC PLAYER WIDGET
        MusicPlayer {
            activePlayer: topBarWindow.activePlayer
            colors: topBarWindow.colors
        }

        // Spacer
        Item {
            Layout.fillWidth: true
        }

        // 2.2 DATE & TIME WIDGET
        ClockWidget {
            colors: topBarWindow.colors
        }

        // Spacer
        Item {
            Layout.fillWidth: true
        }

        // 2.3 WEATHER WIDGET
        WeatherWidget {
            colors: topBarWindow.colors
            weatherCity: topBarWindow.weatherCity
            weatherTemp: topBarWindow.weatherTemp
            weatherDesc: topBarWindow.weatherDesc
            weatherIcon: topBarWindow.weatherIcon
        }
    }

    // Hover trigger MouseArea with expansion logic and exit delay
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onEntered: {
            collapseTimer.stop();
            topBarWindow.expanded = true;
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
        onTriggered: topBarWindow.expanded = false
    }
}

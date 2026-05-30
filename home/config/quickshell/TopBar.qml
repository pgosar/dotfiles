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
    exclusiveZone: 0
    exclusionMode: PanelWindow.ExclusionMode.Ignore
    
    color: "transparent"
    property bool expanded: false
    
    // Collapsed state is 6px height. Expanded is 180px.
    implicitHeight: expanded ? 180 : 6

    Behavior on implicitHeight {
        NumberAnimation {
            duration: 300
            easing.type: Easing.OutQuint
        }
    }

    // Centered pill container
    Rectangle {
        id: pillContainer
        width: 440
        height: parent.height
        anchors.horizontalCenter: parent.horizontalCenter
        
        color: colors.base
        opacity: topBarWindow.expanded ? 0.94 : 1.0
        border.color: colors.purple
        border.width: topBarWindow.expanded ? 1.5 : 3.0
        radius: topBarWindow.expanded ? 16 : 0
        anchors.margins: topBarWindow.expanded ? 4 : 0
        
        Behavior on opacity { NumberAnimation { duration: 200 } }
        Behavior on radius { NumberAnimation { duration: 200 } }

        // Hover trigger (declared first/behind so it doesn't intercept clicks inside content)
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

        // Main content container (only visible when expanded)
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 8
            opacity: topBarWindow.expanded ? 1.0 : 0.0
            visible: topBarWindow.expanded

            Behavior on opacity {
                NumberAnimation { duration: 200 }
            }

            // Top Center: Music Player
            MusicPlayer {
                Layout.fillWidth: true
                activePlayer: topBarWindow.activePlayer
                colors: topBarWindow.colors
            }

            // Separator line
            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: colors.muted
                opacity: 0.3
            }

            // Bottom half: Weather (Left) and Clock/Date (Right)
            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                // Weather Widget (Left Align)
                WeatherWidget {
                    Layout.preferredWidth: 200
                    Layout.alignment: Qt.AlignLeft
                    colors: topBarWindow.colors
                    weatherCity: topBarWindow.weatherCity
                    weatherTemp: topBarWindow.weatherTemp
                    weatherDesc: topBarWindow.weatherDesc
                    weatherIcon: topBarWindow.weatherIcon
                }

                // Divider (Vertical)
                Rectangle {
                    width: 1
                    height: 32
                    color: colors.muted
                    opacity: 0.2
                    Layout.alignment: Qt.AlignVCenter
                }

                // Clock Widget (Right Align)
                ClockWidget {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignRight
                    colors: topBarWindow.colors
                }
            }
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

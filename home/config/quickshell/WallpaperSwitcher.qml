import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Qt.labs.folderlistmodel

PanelWindow {
    id: wallpaperSwitcherWindow

    // Properties passed from root
    required property var modelData
    screen: modelData

    required property var colors

    anchors {
        bottom: true
        left: true
        right: true
    }
    margins {
        left: 60 // Align with LeftBar
    }
    exclusiveZone: 0
    exclusionMode: PanelWindow.ExclusionMode.Ignore
    
    color: "transparent"
    property bool expanded: false

    // Collapsed height is 6px, Expanded is 170px
    implicitHeight: (root.wallpaperSwitcherOpen || expanded) ? 170 : 6

    Behavior on implicitHeight {
        NumberAnimation {
            duration: 300
            easing.type: Easing.OutQuint
        }
    }

    // Centered pill container
    Rectangle {
        id: panelContainer
        width: 760
        height: parent.height
        anchors.horizontalCenter: parent.horizontalCenter

        color: colors.base
        opacity: (wallpaperSwitcherWindow.expanded || root.wallpaperSwitcherOpen) ? 0.94 : 1.0
        border.color: colors.purple
        border.width: (wallpaperSwitcherWindow.expanded || root.wallpaperSwitcherOpen) ? 1.5 : 3.0
        
        // Rounded corners on the top, flat on the bottom
        topLeftRadius: (wallpaperSwitcherWindow.expanded || root.wallpaperSwitcherOpen) ? 16 : 0
        topRightRadius: (wallpaperSwitcherWindow.expanded || root.wallpaperSwitcherOpen) ? 16 : 0
        bottomLeftRadius: 0
        bottomRightRadius: 0
        
        anchors.margins: (wallpaperSwitcherWindow.expanded || root.wallpaperSwitcherOpen) ? 4 : 0

        Behavior on opacity { NumberAnimation { duration: 200 } }

        // Hover trigger (detect hover on the bottom edge)
        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onEntered: {
                collapseTimer.stop();
                wallpaperSwitcherWindow.expanded = true;
            }
            onExited: {
                collapseTimer.restart();
            }
        }

        // Expanded Panel Content
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 8
            opacity: (wallpaperSwitcherWindow.expanded || root.wallpaperSwitcherOpen) ? 1.0 : 0.0
            visible: (wallpaperSwitcherWindow.expanded || root.wallpaperSwitcherOpen)

            Behavior on opacity {
                NumberAnimation { duration: 200 }
            }

            // Title
            Text {
                text: "Select Wallpaper & Color Theme"
                color: colors.text
                Layout.alignment: Qt.AlignHCenter
                font {
                    family: "JetBrainsMono Nerd Font"
                    pixelSize: 14
                    bold: true
                }
            }

            // Separator
            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: colors.muted
                opacity: 0.3
            }

            // Scrollable Horizontal ListView of Wallpapers
            ListView {
                id: wallpaperListView
                Layout.fillWidth: true
                Layout.fillHeight: true
                orientation: ListView.Horizontal
                spacing: 12
                clip: true
                
                // Add horizontal margins inside the list view
                leftMargin: 10
                rightMargin: 10

                model: FolderListModel {
                    id: folderModel
                    folder: "file:///home/chilly/code/dotfiles/home/walls"
                    nameFilters: ["*.png", "*.jpg", "*.jpeg", "*.webp"]
                }

                delegate: Rectangle {
                    id: wrapper
                    width: 140
                    height: 90
                    radius: 8
                    color: colors.surface
                    
                    // Highlight active wallpaper or hovered wallpaper
                    property string cleanPath: fileUrl.toString().replace("file://", "")
                    property bool isActive: root.activeWallpaperPath === cleanPath
                    
                    border.color: isActive ? colors.peach : (thumbHover.containsMouse ? colors.blue : "transparent")
                    border.width: isActive ? 2.5 : 1.5

                    Behavior on border.color { ColorAnimation { duration: 150 } }

                    // Image container
                    Image {
                        anchors.fill: parent
                        anchors.margins: 3
                        source: fileUrl
                        sourceSize.width: 134
                        sourceSize.height: 84
                        fillMode: Image.PreserveAspectCrop
                        clip: true

                        // Rounded corners for the image itself
                        Rectangle {
                            anchors.fill: parent
                            color: "transparent"
                            border.color: colors.surface
                            border.width: 2
                            radius: 6
                        }
                    }

                    // Hover dim overlay
                    Rectangle {
                        anchors.fill: parent
                        color: "black"
                        opacity: thumbHover.containsMouse ? 0.35 : 0.0
                        radius: 8
                        Behavior on opacity { NumberAnimation { duration: 150 } }
                    }

                    // Filename display on hover
                    Text {
                        text: fileName.substring(0, fileName.lastIndexOf('.'))
                        color: colors.white
                        font {
                            family: "JetBrainsMono Nerd Font"
                            pixelSize: 10
                            bold: true
                        }
                        anchors.centerIn: parent
                        visible: thumbHover.containsMouse
                        horizontalAlignment: Text.AlignHCenter
                        elide: Text.ElideRight
                        width: parent.width - 12
                    }

                    // Interactive click area
                    MouseArea {
                        id: thumbHover
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            console.log("Selected wallpaper:", cleanPath);
                            root.changeWallpaper(cleanPath);
                        }
                    }
                }
            }
        }
    }

    Timer {
        id: collapseTimer
        interval: 400
        running: false
        repeat: false
        onTriggered: wallpaperSwitcherWindow.expanded = false
    }
}

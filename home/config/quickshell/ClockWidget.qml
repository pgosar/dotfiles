import QtQuick
import QtQuick.Layouts

ColumnLayout {
    id: clockWidgetRoot
    Layout.alignment: Qt.AlignHCenter
    spacing: 2

    // Properties
    property var colors

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

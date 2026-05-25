import QtQuick
import QtQuick.Layouts

RowLayout {
    id: weatherWidgetRoot
    Layout.preferredWidth: 320
    Layout.alignment: Qt.AlignRight
    spacing: 12

    // Properties
    property var colors
    property string weatherCity
    property string weatherTemp
    property string weatherDesc
    property string weatherIcon

    Text {
        text: weatherWidgetRoot.weatherIcon
        color: colors.rose
        font {
            family: "JetBrainsMono Nerd Font"
            pixelSize: 32
        }
    }

    ColumnLayout {
        spacing: 2

        Text {
            text: weatherWidgetRoot.weatherTemp + "°F"
            color: colors.rose
            font {
                family: "JetBrainsMono Nerd Font"
                pixelSize: 18
                bold: true
            }
        }

        Text {
            text: weatherWidgetRoot.weatherCity + " • " + weatherWidgetRoot.weatherDesc
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

import QtQuick 2.15
import QtGraphicalEffects 1.12
import "utils.js" as Utils

Rectangle {
    id: topBar

    property string collectionName: ""
    property alias fontFamily: collectionLabel.font.family
    property var themeSettings: null

    color: themeSettings ? themeSettings.bgColor : "#0e0e0e"

    Rectangle {
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: vpx(1)
        color: topBar.themeSettings ? topBar.themeSettings.separatorColor : "#2c2c2c"
        opacity: 0.8
    }

    Row {
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        spacing: vpx(10)

        Item {
            width: vpx(50)
            height: vpx(50)
            anchors.verticalCenter: parent.verticalCenter

            Image {
                id: pegasusLogo
                source: "assets/theme-icons/pegasus.png"
                width: vpx(50)
                height: vpx(50)
                mipmap: true
                anchors.verticalCenter: parent.verticalCenter
                visible: false
            }

            ColorOverlay {
                anchors.fill: pegasusLogo
                source: pegasusLogo
                color: topBar.themeSettings ? topBar.themeSettings.accentColor : "#ffffff"
                visible: true
            }
        }

        Text {
            id: collectionLabel
            text: topBar.collectionName
            color: topBar.themeSettings ? topBar.themeSettings.textPrimary : "#ffffff"
            font.bold: true
            font.pixelSize: Math.min(topBar.height / 2, topBar.width / 40)
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    Row {
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        spacing: vpx(10)

        Row {
            id: clockRow
            spacing: vpx(5)

            Timer {
                id: clockTimer
                interval: 1000
                repeat: true
                running: true
                onTriggered: clockText.text = Qt.formatDateTime(new Date(), "dd-MM HH:mm")
            }

            Text {
                id: clockText
                text: Qt.formatDateTime(new Date(), "dd-MM HH:mm")
                color: topBar.themeSettings ? topBar.themeSettings.textPrimary : "#ffffff"
                font.pixelSize: Math.min(topBar.height / 3, topBar.width / 40)
                font.family: topBar.fontFamily
                anchors.verticalCenter: parent.verticalCenter
            }

            Item {
                width: vpx(20)
                height: vpx(20)
                anchors.verticalCenter: parent.verticalCenter

                Image {
                    id: clockIcon
                    source: "assets/theme-icons/clock.png"
                    width: vpx(20)
                    height: vpx(20)
                    anchors.verticalCenter: parent.verticalCenter
                    sourceSize { width: vpx(20); height: vpx(20) }
                    visible: false
                }
                ColorOverlay {
                    anchors.fill: clockIcon
                    source: clockIcon
                    color: topBar.themeSettings ? topBar.themeSettings.textPrimary : "#ffffff"
                }
            }
        }

        Row {
            id: batteryRow
            spacing: vpx(5)

            Text {
                text: isNaN(api.device.batteryPercent)
                ? "N/A"
                : (api.device.batteryPercent * 100).toFixed(0) + "%"
                color: topBar.themeSettings ? topBar.themeSettings.textPrimary : "#ffffff"
                font.pixelSize: Math.min(topBar.height / 3, topBar.width / 40)
                font.family: topBar.fontFamily
                anchors.verticalCenter: parent.verticalCenter
            }

            Item {
                width: topBar.width * 0.014
                height: topBar.height * 0.034
                anchors.verticalCenter: parent.verticalCenter

                Image {
                    id: batteryIcon
                    source: Utils.getBatteryIcon(api.device.batteryPercent,
                                                 api.device.batteryCharging)
                    width: parent.width
                    height: parent.height
                    mipmap: true
                    visible: false
                }
                ColorOverlay {
                    anchors.fill: batteryIcon
                    source: batteryIcon
                    color: topBar.themeSettings ? topBar.themeSettings.textPrimary : "#ffffff"
                }
            }
        }
    }
}

import QtQuick 2.15
import QtGraphicalEffects 1.12
import "utils.js" as Utils

Rectangle {
    id: infoPanel

    property var selectedGame: null
    property string currentImageType: "boxFront"
    property string fontFamily: ""
    property int gameCount: 0
    property int gameCurrentIndex: 0
    property string collectionShortName: ""
    property bool showLogo: true
    property string playTimeDisplay: "Play Time:"
    property string lastPlayedDisplay: "Last Played:"
    property string favoriteDisplay: "Favorite: "
    property var themeSettings: null

    color: "transparent"

    Behavior on width {
        NumberAnimation { duration: 300; easing.type: Easing.InOutQuad }
    }

    onVisibleChanged: { if (!visible) selectedGame = null; }

    Item {
        anchors.fill: parent

        Image {
            id: pegasusTitle
            anchors.topMargin: 10
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            source: "assets/theme-icons/pegasus-title.png"
            mipmap: true
            fillMode: Image.PreserveAspectFit
            width: parent.width * 0.85
            height: parent.height * 0.40
            visible: infoPanel.showLogo
            sourceSize { width: 356; height: 356 }
            layer.enabled: true
            layer.effect: ColorOverlay {
                color: infoPanel.themeSettings ? infoPanel.themeSettings.accentColor : "#ffffff"
            }
        }

        Item {
            id: boxFrontContainer
            anchors.topMargin: 10
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width * 0.85
            height: parent.height * 0.40
            visible: !infoPanel.showLogo

            Image {
                id: boxFrontImage
                anchors.fill: parent
                source: infoPanel.selectedGame
                ? infoPanel.selectedGame.assets[infoPanel.currentImageType]
                : ""
                fillMode: Image.PreserveAspectFit
                sourceSize { width: 456; height: 456 }
                visible: status === Image.Ready
            }

            Image {
                id: noFoundImage
                anchors.topMargin: 10
                anchors.top: parent.top
                anchors.horizontalCenter: parent.horizontalCenter
                source: "assets/theme-icons/nofound.png"
                fillMode: Image.PreserveAspectFit
                width: parent.width * 0.90
                height: parent.height * 0.60
                sourceSize { width: 200; height: 200 }
                visible: boxFrontImage.status !== Image.Ready
                layer.enabled: true
                layer.effect: ColorOverlay {
                    color: infoPanel.themeSettings ? infoPanel.themeSettings.textSecondary : "#c0c0c0"
                }
            }
        }

        Column {
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.leftMargin: 20
            anchors.bottomMargin: 30
            spacing: 10
            width: parent.width - 40

            Text {
                text: "Games:\n" + (infoPanel.gameCount > 0
                ? (infoPanel.gameCurrentIndex + 1) + "/" + infoPanel.gameCount
                : "0/0")
                font.pixelSize: Math.min(infoPanel.height / 28, infoPanel.width / 18)
                font.family: infoPanel.fontFamily
                color: infoPanel.themeSettings ? infoPanel.themeSettings.textSecondary : "#c0c0c0"
                width: parent.width
                wrapMode: Text.Wrap
            }

            Text {
                text: "Collection:\n" + infoPanel.collectionShortName
                font.pixelSize: Math.min(infoPanel.height / 28, infoPanel.width / 18)
                font.family: infoPanel.fontFamily
                color: infoPanel.themeSettings ? infoPanel.themeSettings.textSecondary : "#c0c0c0"
                width: parent.width
                wrapMode: Text.Wrap
            }

            Text {
                text: infoPanel.playTimeDisplay
                font.pixelSize: Math.min(infoPanel.height / 28, infoPanel.width / 18)
                font.family: infoPanel.fontFamily
                color: infoPanel.themeSettings ? infoPanel.themeSettings.textSecondary : "#c0c0c0"
                width: parent.width
                wrapMode: Text.Wrap
            }

            Text {
                text: infoPanel.lastPlayedDisplay
                font.pixelSize: Math.min(infoPanel.height / 28, infoPanel.width / 18)
                font.family: infoPanel.fontFamily
                color: infoPanel.themeSettings ? infoPanel.themeSettings.textSecondary : "#c0c0c0"
                width: parent.width
                wrapMode: Text.Wrap
            }

            Text {
                text: infoPanel.favoriteDisplay
                font.pixelSize: Math.min(infoPanel.height / 28, infoPanel.width / 18)
                font.family: infoPanel.fontFamily
                color: infoPanel.themeSettings ? infoPanel.themeSettings.textSecondary : "#c0c0c0"
                width: parent.width
                wrapMode: Text.Wrap
            }
        }
    }
}

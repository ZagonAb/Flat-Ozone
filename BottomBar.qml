import QtQuick 2.15
import QtGraphicalEffects 1.12

Rectangle {
    id: bottomBar

    property bool gameListFocused: false
    property bool settingsFocused: false
    property alias fontFamily: hintFont.name
    property string _fontFamily: ""
    property var themeSettings: null

    color: themeSettings ? themeSettings.bgColor : "#0e0e0e"

    Rectangle {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: vpx(1)
        color: bottomBar.themeSettings ? bottomBar.themeSettings.separatorColor : "#2c2c2c"
        opacity: 0.8
    }

    component HintIcon : Item {
        property string iconSource: ""
        property var theTheme: null
        width: bottomBar.width * 0.02
        height: bottomBar.height * 0.35
        anchors.verticalCenter: parent ? parent.verticalCenter : undefined

        Image {
            id: _img
            source: iconSource
            anchors.fill: parent
            sourceSize { width: vpx(64); height: vpx(64) }
            visible: false
        }
        ColorOverlay {
            anchors.fill: _img
            source: _img
            color: theTheme ? theTheme.textPrimary : "#ffffff"
        }
    }

    Row {
        id: mainRow
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        spacing: vpx(20)

        Behavior on anchors.rightMargin {
            NumberAnimation { duration: 300; easing.type: Easing.InOutQuad }
        }

        Row {
            id: settingsApplyRow
            spacing: vpx(5)
            visible: bottomBar.settingsFocused
            opacity: bottomBar.settingsFocused ? 1.0 : 0.0
            Behavior on opacity { NumberAnimation { duration: 300; easing.type: Easing.InOutQuad } }
            onOpacityChanged: visible = (opacity !== 0.0)

            HintIcon {
                iconSource: "assets/theme-icons/ok.png"
                theTheme: bottomBar.themeSettings
                height: bottomBar.height * 0.35
                width: bottomBar.width * 0.02
            }
            Text {
                text: " Apply"
                color: bottomBar.themeSettings ? bottomBar.themeSettings.textPrimary : "#ffffff"
                font.family: bottomBar._fontFamily
                font.pixelSize: bottomBar.height * 0.25
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        Row {
            id: detailsRow
            spacing: vpx(5)
            visible: bottomBar.gameListFocused
            opacity: bottomBar.gameListFocused ? 1.0 : 0.0
            Behavior on opacity { NumberAnimation { duration: 300; easing.type: Easing.InOutQuad } }
            onOpacityChanged: visible = (opacity !== 0.0)

            HintIcon {
                iconSource: "assets/theme-icons/details.png"
                theTheme: bottomBar.themeSettings
                height: bottomBar.height * 0.35
                width: bottomBar.width * 0.02
            }
            Text {
                text: " Cycle thumbnail"
                color: bottomBar.themeSettings ? bottomBar.themeSettings.textPrimary : "#ffffff"
                font.family: bottomBar._fontFamily
                font.pixelSize: bottomBar.height * 0.25
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        Row {
            id: favoriteRow
            spacing: vpx(5)
            visible: bottomBar.gameListFocused
            opacity: bottomBar.gameListFocused ? 1.0 : 0.0
            Behavior on opacity { NumberAnimation { duration: 300; easing.type: Easing.InOutQuad } }
            onOpacityChanged: visible = (opacity !== 0.0)

            HintIcon {
                iconSource: "assets/theme-icons/favorite.png"
                theTheme: bottomBar.themeSettings
                height: bottomBar.height * 0.35
                width: bottomBar.width * 0.02
            }
            Text {
                text: " Favorite"
                color: bottomBar.themeSettings ? bottomBar.themeSettings.textPrimary : "#ffffff"
                font.family: bottomBar._fontFamily
                font.pixelSize: bottomBar.height * 0.25
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        Row {
            id: okRow
            spacing: vpx(5)
            visible: bottomBar.gameListFocused
            opacity: bottomBar.gameListFocused ? 1.0 : 0.0
            Behavior on opacity { NumberAnimation { duration: 300; easing.type: Easing.InOutQuad } }
            onOpacityChanged: visible = (opacity !== 0.0)

            HintIcon {
                iconSource: "assets/theme-icons/ok.png"
                theTheme: bottomBar.themeSettings
                height: bottomBar.height * 0.35
                width: bottomBar.width * 0.02
            }
            Text {
                text: " OK"
                color: bottomBar.themeSettings ? bottomBar.themeSettings.textPrimary : "#ffffff"
                font.family: bottomBar._fontFamily
                font.pixelSize: bottomBar.height * 0.25
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        Row {
            id: backRow
            spacing: vpx(5)

            HintIcon {
                iconSource: "assets/theme-icons/back.png"
                theTheme: bottomBar.themeSettings
                height: bottomBar.height * 0.35
                width: bottomBar.width * 0.02
            }
            Text {
                text: " Back"
                color: bottomBar.themeSettings ? bottomBar.themeSettings.textPrimary : "#ffffff"
                font.family: bottomBar._fontFamily
                font.pixelSize: bottomBar.height * 0.25
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }

    states: [
        State {
            name: "hidden"
            when: !bottomBar.gameListFocused && !bottomBar.settingsFocused
            PropertyChanges {
                target: mainRow
                anchors.rightMargin: backRow.width + bottomBar.width * 0.003
            }
        },
        State {
            name: "visible"
            when: bottomBar.gameListFocused || bottomBar.settingsFocused
            PropertyChanges {
                target: mainRow
                anchors.rightMargin: 0
            }
        }
    ]

    Item {
        id: hintFont
        property string name: ""
    }
}

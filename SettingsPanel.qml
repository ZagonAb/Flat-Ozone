import QtQuick 2.15
import QtGraphicalEffects 1.12

FocusScope {
    id: settingsPanel

    property var themeSettings: null
    property string fontFamily: ""
    property var sounds: null
    property var soundManager: null

    signal navigateLeft()

    Rectangle {
        anchors.fill: parent
        color: themeSettings ? themeSettings.bgColor : "#0e0e0e"
    }

    Text {
        id: sectionTitle
        text: "Color Theme"
        color: themeSettings ? themeSettings.textSecondary : "#c0c0c0"
        font.family: settingsPanel.fontFamily
        font.pixelSize: settingsPanel.height * 0.028
        font.bold: true
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.topMargin: settingsPanel.height * 0.03
        anchors.leftMargin: settingsPanel.width * 0.06
    }

    Rectangle {
        id: titleSep
        anchors.top: sectionTitle.bottom
        anchors.topMargin: vpx(6)
        anchors.left: parent.left
        anchors.leftMargin: settingsPanel.width * 0.06
        width: settingsPanel.width * 0.88
        height: vpx(1)
        color: themeSettings ? themeSettings.separatorColor : "#2c2c2c"
        opacity: 0.8
    }

    ListModel {
        id: settingsModel

        function addThemes() {
            for (var i = 0; i < themeSettings.themes.length; ++i) {
                append({ type: "theme", themeIndex: i, name: themeSettings.themes[i].name })
            }
        }

        function addToggle() {
            append({ type: "header", name: "Sound" })
            append({ type: "toggle", name: "Background Music", enabled: soundManager ? soundManager.bgmEnabled : true })
        }

        function toggleIndex() {
            for (var i = 0; i < count; i++) {
                if (get(i).type === "toggle") return i
            }
            return -1
        }
    }

    Connections {
        target: soundManager
        function onBgmEnabledChanged() {
            var idx = settingsModel.toggleIndex()
            if (idx >= 0) {
                settingsModel.setProperty(idx, "enabled", soundManager.bgmEnabled)
            }
        }
    }

    ListView {
        id: themeList
        anchors.top: titleSep.bottom
        anchors.topMargin: vpx(4)
        anchors.bottom: parent.bottom
        anchors.bottomMargin: settingsPanel.height * 0.04
        anchors.left: parent.left
        anchors.right: parent.right
        clip: true
        focus: true
        keyNavigationEnabled: false

        model: settingsModel

        delegate: Rectangle {
            readonly property bool isTheme: model.type === "theme"
            readonly property bool isToggle: model.type === "toggle"
            readonly property bool isHeader: model.type === "header"
            readonly property bool isActive: isTheme && themeSettings && model.themeIndex === themeSettings.currentThemeIndex
            readonly property bool isSelected: themeList.currentIndex === index && themeList.activeFocus && !isHeader

            width: themeList.width
            height: isHeader ? settingsPanel.height * 0.088 : settingsPanel.height * 0.066
            color: isSelected ? (themeSettings ? themeSettings.highlightColor : "#303030") : "transparent"

            Text {
                visible: isHeader
                text: model.name
                color: themeSettings ? themeSettings.textSecondary : "#c0c0c0"
                font.family: settingsPanel.fontFamily
                font.pixelSize: settingsPanel.height * 0.028
                font.bold: true
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.bottomMargin: vpx(6)
                anchors.leftMargin: settingsPanel.width * 0.06
            }

            Rectangle {
                visible: isHeader
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.leftMargin: settingsPanel.width * 0.06
                width: settingsPanel.width * 0.88
                height: vpx(1)
                color: themeSettings ? themeSettings.separatorColor : "#2c2c2c"
                opacity: 0.8
            }

            Rectangle {
                anchors.left: parent.left
                anchors.leftMargin: settingsPanel.width * 0.06
                anchors.verticalCenter: parent.verticalCenter
                width: vpx(3)
                height: parent.height * 0.55
                radius: vpx(1)
                visible: isTheme && isActive
                color: themeSettings ? themeSettings.accentColor : "#ffffff"
            }

            Text {
                id: itemText
                anchors.left: parent.left
                anchors.leftMargin: settingsPanel.width * 0.10
                anchors.verticalCenter: parent.verticalCenter
                visible: !isHeader
                text: model.name
                font.family: settingsPanel.fontFamily
                font.pixelSize: settingsPanel.height * 0.028
                color: {
                    if (isSelected) return themeSettings ? themeSettings.textPrimary : "#ffffff"
                    if (isActive)   return themeSettings ? themeSettings.textPrimary : "#ffffff"
                    return themeSettings ? themeSettings.textSecondary : "#c0c0c0"
                }
            }

            Item {
                anchors.right: parent.right
                anchors.rightMargin: settingsPanel.width * 0.06
                anchors.verticalCenter: parent.verticalCenter
                width: settingsPanel.height * 0.1
                height: settingsPanel.height * 0.1
                visible: isToggle

                Item {
                    anchors.fill: parent
                    visible: model.enabled

                    Image {
                        id: onIcon
                        source: "assets/theme-icons/on.png"
                        anchors.fill: parent
                        visible: false
                        mipmap: true
                    }
                    ColorOverlay {
                        anchors.fill: onIcon
                        source: onIcon
                        color: themeSettings ? themeSettings.accentColor : "#ffffff"
                    }
                }

                Item {
                    anchors.fill: parent
                    visible: !model.enabled

                    Image {
                        id: offIcon
                        source: "assets/theme-icons/off.png"
                        anchors.fill: parent
                        visible: false
                        mipmap: true
                    }
                    ColorOverlay {
                        anchors.fill: offIcon
                        source: offIcon
                        color: themeSettings ? themeSettings.textSecondary : "#c0c0c0"
                    }
                }
            }

            Text {
                text: "✓"
                visible: isTheme && isActive
                anchors.right: parent.right
                anchors.rightMargin: settingsPanel.width * 0.06
                anchors.verticalCenter: parent.verticalCenter
                font.pixelSize: settingsPanel.height * 0.032
                color: themeSettings ? themeSettings.accentColor : "#ffffff"
            }

            Rectangle {
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.leftMargin: settingsPanel.width * 0.06
                width: parent.width - settingsPanel.width * 0.12
                height: vpx(1)
                color: themeSettings ? themeSettings.separatorColor : "#2c2c2c"
                opacity: 0.35
                visible: !isHeader && index < settingsModel.count - 1
            }
        }

        Component.onCompleted: {
            settingsModel.addThemes()
            settingsModel.addToggle()
        }

        onCurrentIndexChanged: {
            positionViewAtIndex(currentIndex, ListView.Contain)
        }

        Keys.onUpPressed: {
            var next = currentIndex - 1
            if (next < 0) next = count - 1
            if (settingsModel.get(next).type === "header") next = next - 1
            if (next < 0) next = count - 1
            currentIndex = next
            if (sounds) sounds.playUp()
        }

        Keys.onDownPressed: {
            var next = currentIndex + 1
            if (next >= count) next = 0
            if (settingsModel.get(next).type === "header") next = next + 1
            if (next >= count) next = 0
            currentIndex = next
            if (sounds) sounds.playDown()
        }

        Keys.onPressed: {
            if (event.isAutoRepeat) return

            if (api.keys.isAccept(event)) {
                event.accepted = true
                var item = settingsModel.get(currentIndex)
                if (item.type === "theme") {
                    if (themeSettings) themeSettings.applyTheme(item.themeIndex)
                    if (sounds) sounds.playFavo()
                } else if (item.type === "toggle") {
                    soundManager.toggleBgm()
                    if (sounds) sounds.playFavo()
                }
            } else if (api.keys.isCancel(event) || event.key === Qt.Key_Left) {
                event.accepted = true
                settingsPanel.navigateLeft()
                if (sounds) sounds.playDown()
            }
        }
    }

    Rectangle {
        anchors.bottom: themeList.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: settingsPanel.height * 0.08
        visible: themeList.contentHeight > themeList.height
        gradient: Gradient {
            GradientStop { position: 0.0; color: "transparent" }
            GradientStop { position: 1.0; color: themeSettings ? themeSettings.bgColor : "#0e0e0e" }
        }
    }
}

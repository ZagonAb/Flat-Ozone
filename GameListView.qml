import QtQuick 2.15
import QtGraphicalEffects 1.12
import "utils.js" as Utils

ListView {
    id: gameList

    property string fontFamily: ""
    property string currentCollectionName: ""
    property var themeSettings: null
    property var sounds: null

    signal gameSelected(var game)
    signal favoriteToggled(var game)
    signal imageCycleRequested()
    signal navigateLeft()
    signal gameInfoUpdateRequested()

    clip: true
    focus: false
    property int indexToPosition: -1

    Row {
        anchors.centerIn: parent
        spacing: vpx(5)
        visible: gameList.count === 0

        Image {
            source: "assets/theme-icons/info2.png"
            width: vpx(64)
            height: vpx(64)
            anchors.verticalCenter: parent.verticalCenter
            sourceSize { width: vpx(64); height: vpx(64) }
        }

        Text {
            text: "No " + gameList.currentCollectionName + " Available"
            font.pixelSize: vpx(20)
            color: gameList.themeSettings ? gameList.themeSettings.textPrimary : "#ffffff"
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    delegate: Rectangle {
        width: gameList.width
        height: vpx(57)
        color: gameList.currentIndex === index && gameList.focus
        ? (gameList.themeSettings ? gameList.themeSettings.highlightColor : "#303030")
        : "transparent"
        border.width: vpx(2)
        border.color: gameList.currentIndex === index && gameList.focus
        ? (gameList.themeSettings ? gameList.themeSettings.highlightColor : "#303030")
        : "transparent"
        clip: true

        Row {
            anchors.centerIn: parent
            spacing: vpx(10)

            Rectangle { width: vpx(20); height: parent.height; color: "transparent" }

            Item {
                width: root.width * 0.065
                height: root.height * 0.065
                anchors.verticalCenter: parent.verticalCenter

                Image {
                    id: contentIcon
                    source: "assets/systems/" + Utils.getShortNameForGame(model, api.collections) + "-content.png"
                    width: parent.width
                    height: parent.height
                    fillMode: Image.PreserveAspectFit
                    mipmap: true
                    visible: false
                }

                ColorOverlay {
                    anchors.fill: contentIcon
                    source: contentIcon
                    color: {
                        var ts = gameList.themeSettings;
                        var isSelected = gameList.currentIndex === index && gameList.focus;
                        if (isSelected) return ts ? ts.accentColor : "#ffffff";
                        return ts ? ts.textSecondary : "#c0c0c0";
                    }
                }
            }

            Item {
                    id: gameMarqueeContainer
                    anchors.verticalCenter: parent.verticalCenter
                    width: gameList.width - vpx(20) - root.width * 0.065 - vpx(10) - vpx(20) - vpx(16)
                    height: gameMarqueeText1.height
                    clip: true

                    property bool isSelected: gameList.currentIndex === index && gameList.focus
                    property bool needsScroll: gameMarqueeText1.implicitWidth > gameMarqueeContainer.width
                    property real scrollOffset: 0
                    property real cycleWidth: gameMarqueeText1.implicitWidth + gameMarqueeSep.implicitWidth

                    function textColor() {
                        var ts = gameList.themeSettings;
                        if (isSelected) return ts ? ts.textPrimary : "#ffffff";
                        return ts ? ts.textSecondary : "#c0c0c0";
                    }

                    Text {
                        id: gameMarqueeText1
                        text: model.title
                        font.pixelSize: root.width * 0.016
                        font.family: gameList.fontFamily
                        color: gameMarqueeContainer.textColor()
                        elide: gameMarqueeContainer.isSelected ? Text.ElideNone : Text.ElideRight
                        width: gameMarqueeContainer.isSelected ? implicitWidth : gameMarqueeContainer.width
                        x: -gameMarqueeContainer.scrollOffset
                        y: 0
                    }

                    Text {
                        id: gameMarqueeSep
                        text: "  •  "
                        font.pixelSize: root.width * 0.016
                        font.family: gameList.fontFamily
                        color: gameMarqueeContainer.textColor()
                        elide: Text.ElideNone
                        x: gameMarqueeText1.implicitWidth - gameMarqueeContainer.scrollOffset
                        y: 0
                        visible: gameMarqueeContainer.needsScroll
                    }

                    Text {
                        id: gameMarqueeText2
                        text: model.title
                        font.pixelSize: root.width * 0.016
                        font.family: gameList.fontFamily
                        color: gameMarqueeContainer.textColor()
                        elide: Text.ElideNone
                        x: gameMarqueeText1.implicitWidth + gameMarqueeSep.implicitWidth - gameMarqueeContainer.scrollOffset
                        y: 0
                        visible: gameMarqueeContainer.needsScroll
                    }

                    NumberAnimation {
                        id: gameMarqueeAnim
                        target: gameMarqueeContainer
                        property: "scrollOffset"
                        from: 0
                        to: gameMarqueeContainer.cycleWidth
                        duration: gameMarqueeContainer.cycleWidth * 22
                        easing.type: Easing.Linear
                        loops: Animation.Infinite
                        running: false
                    }

                    onIsSelectedChanged: {
                        gameMarqueeContainer.scrollOffset = 0;
                        gameMarqueeAnim.stop();
                        if (isSelected && needsScroll) {
                            gameMarqueeAnim.start();
                        }
                    }

                    onNeedsScrollChanged: {
                        if (isSelected && needsScroll) {
                            gameMarqueeContainer.scrollOffset = 0;
                            gameMarqueeAnim.start();
                        } else {
                            gameMarqueeAnim.stop();
                            gameMarqueeContainer.scrollOffset = 0;
                        }
                    }
                }
        }

        Rectangle {
            width: parent.width
            height: vpx(1)
            color: gameList.themeSettings ? gameList.themeSettings.separatorColor : "#2c2c2c"
            opacity: 0.4
            visible: index !== gameList.count - 1
        }
    }

    onIndexToPositionChanged: {
        if (indexToPosition >= 0)
            positionViewAtIndex(indexToPosition, ListView.Center);
    }
    Behavior on indexToPosition {
        NumberAnimation { duration: 200 }
    }

    onCurrentItemChanged: {
        if (gameList.count > 0 && gameList.focus) {
            indexToPosition = currentIndex;
            gameList.gameInfoUpdateRequested();
        }
    }

    onFocusChanged: {
        gameList.gameInfoUpdateRequested();
    }

    Keys.onUpPressed: {
        currentIndex = (currentIndex === 0) ? count - 1 : currentIndex - 1;
        if (sounds) sounds.playUp();
    }

    Keys.onDownPressed: {
        currentIndex = (currentIndex === count - 1) ? 0 : currentIndex + 1;
        if (sounds) sounds.playDown();
    }

    Keys.onLeftPressed: {
        gameList.navigateLeft();
        if (sounds) sounds.playDown();
    }

    Keys.onPressed: {
        if (event.isAutoRepeat) return;

        if (api.keys.isAccept(event)) {
            event.accepted = true;
            var sel = gameList.model.get(gameList.currentIndex);
            gameList.gameSelected(sel);
        } else if (api.keys.isDetails(event)) {
            event.accepted = true;
            if (sounds) sounds.playFavo();
            var sel2 = gameList.model.get(gameList.currentIndex);
            gameList.favoriteToggled(sel2);
        } else if (api.keys.isFilters(event)) {
            event.accepted = true;
            if (sounds) sounds.playUp();
            gameList.imageCycleRequested();
        } else if (api.keys.isCancel(event)) {
            event.accepted = true;
            gameList.navigateLeft();
            if (sounds) sounds.playDown();
        }
    }
}

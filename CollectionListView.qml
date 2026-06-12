import QtQuick 2.15
import QtGraphicalEffects 1.12

ListView {
    id: collectionList

    property string currentShortName: ""
    property string currentName: ""
    property string fontFamily: ""
    property var themeSettings: null
    property var sounds: null

    signal collectionSelected(var gamesModel)
    signal navigateRight()
    signal settingsSelected()
    signal settingsHighlighted()

    clip: true
    focus: true

    property int itemHeight: vpx(63)
    property int visibleItemCount: Math.floor(height / itemHeight)
    property int indexToPosition: -1

    delegate: Column {
        width: collectionList.width

        Rectangle {
            width: collectionList.width
            height: vpx(63)
            color: collectionList.currentIndex === index && collectionList.focus
            ? (collectionList.themeSettings ? collectionList.themeSettings.highlightColor : "#303030")
            : "transparent"
            border.width: vpx(2)
            border.color: collectionList.currentIndex === index && collectionList.focus
            ? (collectionList.themeSettings ? collectionList.themeSettings.highlightColor : "#303030")
            : "transparent"

            Row {
                anchors.centerIn: parent
                spacing: vpx(10)
                width: collectionList.focus ? parent.width : vpx(40)

                Rectangle { width: vpx(1); height: parent.height; color: "transparent" }

                Item {
                    width: vpx(50)
                    height: vpx(50)
                    anchors.verticalCenter: parent.verticalCenter

                    Image {
                        id: sysIcon
                        source: "assets/systems/" + model.shortName + ".png"
                        width: vpx(50)
                        height: vpx(50)
                        fillMode: Image.PreserveAspectFit
                        mipmap: true
                        visible: false
                    }

                    ColorOverlay {
                        anchors.fill: sysIcon
                        source: sysIcon
                        color: {
                            var ts = collectionList.themeSettings;
                            var isSelected = collectionList.currentIndex === index && collectionList.focus;
                            if (isSelected) {
                                return ts ? ts.accentColor : "#ffffff";
                            }
                            return ts ? ts.textSecondary : "#c0c0c0";
                        }
                    }
                }

                Item {
                    id: marqueeContainer
                    visible: collectionList.focus
                    anchors.verticalCenter: parent.verticalCenter
                    width: collectionList.focus
                        ? Math.max(0, collectionList.width - vpx(10) - vpx(30) - vpx(20) - vpx(16))
                        : vpx(30)
                    height: marqueeText1.height
                    clip: true

                    property bool isSelected: collectionList.currentIndex === index && collectionList.focus
                    property bool needsScroll: marqueeText1.implicitWidth > marqueeContainer.width
                    property real scrollOffset: 0
                    property real cycleWidth: marqueeText1.implicitWidth + marqueeSep.implicitWidth

                    function textColor() {
                        var ts = collectionList.themeSettings;
                        if (isSelected) {
                            return model.isSettings
                                ? (ts ? ts.accentColor : "#aaaaff")
                                : (ts ? ts.textPrimary : "#ffffff");
                        }
                        return model.isSettings
                            ? (ts ? ts.accentColor : "#8888cc")
                            : (ts ? ts.textSecondary : "#c0c0c0");
                    }

                    Text {
                        id: marqueeText1
                        text: model.name
                        font.pixelSize: root.width * 0.018
                        font.family: collectionList.fontFamily
                        font.bold: model.isSettings
                        color: marqueeContainer.textColor()
                        elide: marqueeContainer.isSelected ? Text.ElideNone : Text.ElideRight
                        width: marqueeContainer.isSelected ? implicitWidth : marqueeContainer.width
                        x: -marqueeContainer.scrollOffset
                        y: 0
                    }

                    Text {
                        id: marqueeSep
                        text: "  •  "
                        font.pixelSize: root.width * 0.018
                        font.family: collectionList.fontFamily
                        color: marqueeContainer.textColor()
                        elide: Text.ElideNone
                        x: marqueeText1.implicitWidth - marqueeContainer.scrollOffset
                        y: 0
                        visible: marqueeContainer.needsScroll
                    }

                    Text {
                        id: marqueeText2
                        text: model.name
                        font.pixelSize: root.width * 0.018
                        font.family: collectionList.fontFamily
                        font.bold: model.isSettings
                        color: marqueeContainer.textColor()
                        elide: Text.ElideNone
                        x: marqueeText1.implicitWidth + marqueeSep.implicitWidth - marqueeContainer.scrollOffset
                        y: 0
                        visible: marqueeContainer.needsScroll
                    }

                    NumberAnimation {
                        id: marqueeAnim
                        target: marqueeContainer
                        property: "scrollOffset"
                        from: 0
                        to: marqueeContainer.cycleWidth
                        duration: marqueeContainer.cycleWidth * 22
                        easing.type: Easing.Linear
                        loops: Animation.Infinite
                        running: false
                    }

                    onIsSelectedChanged: {
                        marqueeContainer.scrollOffset = 0;
                        marqueeAnim.stop();
                        if (isSelected && needsScroll) {
                            marqueeAnim.start();
                        }
                    }

                    onNeedsScrollChanged: {
                        if (isSelected && needsScroll) {
                            marqueeContainer.scrollOffset = 0;
                            marqueeAnim.start();
                        } else {
                            marqueeAnim.stop();
                            marqueeContainer.scrollOffset = 0;
                        }
                    }
                }
            }
        }

        Rectangle {
            width: parent.width * 0.90
            height: vpx(1)
            color: collectionList.themeSettings ? collectionList.themeSettings.separatorColor : "#2c2c2c"
            opacity: 0.5
            visible: index === 1 || (model.isSettings)
        }
    }

    Behavior on width {
        NumberAnimation { duration: 300; easing.type: Easing.InOutQuad }
    }

    onIndexToPositionChanged: {
        if (indexToPosition >= 0)
            positionViewAtIndex(indexToPosition, ListView.Center);
    }
    Behavior on indexToPosition {
        NumberAnimation { duration: 200 }
    }

    onCurrentIndexChanged: {
        var selected = model.get(currentIndex);
        currentShortName = selected.shortName;
        currentName = selected.name;
        indexToPosition = currentIndex;

        if (selected.isSettings) {
            collectionList.settingsHighlighted();
        } else {
            collectionList.collectionSelected(selected.games);
        }
    }

    Keys.onUpPressed: {
        currentIndex = (currentIndex > 0) ? currentIndex - 1 : count - 1;
        if (sounds) sounds.playUp();
    }

    Keys.onDownPressed: {
        currentIndex = (currentIndex < count - 1) ? currentIndex + 1 : 0;
        if (sounds) sounds.playDown();
    }

    Keys.onRightPressed: {
        var selected = model.get(currentIndex);
        if (selected && selected.isSettings) {
            collectionList.settingsSelected();
        } else {
            collectionList.navigateRight();
        }
        if (sounds) sounds.playUp();
    }

    Keys.onPressed: {
        if (!event.isAutoRepeat && api.keys.isCancel(event)) {
            event.accepted = false;
            if (sounds) sounds.playDown();
        }
    }
}

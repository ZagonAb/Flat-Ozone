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

    property int itemHeight: 40
    property int visibleItemCount: Math.floor(height / itemHeight)
    property int indexToPosition: -1

    delegate: Column {
        width: collectionList.width

        Rectangle {
            width: collectionList.width
            height: 40
            color: collectionList.currentIndex === index && collectionList.focus
            ? (collectionList.themeSettings ? collectionList.themeSettings.highlightColor : "#303030")
            : "transparent"
            border.width: 2
            border.color: collectionList.currentIndex === index && collectionList.focus
            ? (collectionList.themeSettings ? collectionList.themeSettings.highlightColor : "#303030")
            : "transparent"

            Row {
                anchors.centerIn: parent
                spacing: 10
                width: collectionList.focus ? parent.width : 40

                Rectangle { width: 0.5; height: parent.height; color: "transparent" }

                Item {
                    width: 40
                    height: 40
                    anchors.verticalCenter: parent.verticalCenter

                    Image {
                        id: sysIcon
                        source: "assets/systems/" + model.shortName + ".png"
                        width: 40
                        height: 40
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

                Text {
                    visible: collectionList.focus
                    text: model.name
                    font.pixelSize: root.width * 0.012
                    elide: collectionList.focus ? Text.ElideRight : Text.ElideNone
                    color: {
                        var ts = collectionList.themeSettings;
                        var isSelected = collectionList.currentIndex === index && collectionList.focus;
                        if (isSelected) {
                            return model.isSettings
                            ? (ts ? ts.accentColor : "#aaaaff")
                            : (ts ? ts.textPrimary : "#ffffff");
                        }
                        return model.isSettings
                        ? (ts ? ts.accentColor : "#8888cc")
                        : (ts ? ts.textSecondary : "#c0c0c0");
                    }
                    anchors.verticalCenter: parent.verticalCenter
                    font.family: collectionList.fontFamily
                    font.bold: model.isSettings
                    width: collectionList.focus
                    ? Math.max(0, collectionList.width - 10 - 30 - 20)
                    : 30
                }
            }
        }

        Rectangle {
            width: parent.width * 0.90
            height: 1
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

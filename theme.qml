import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.12
import SortFilterProxyModel 0.2
import QtMultimedia 5.8

FocusScope {
    focus: true

    property string collectionShortName: ""

    FontLoader {
        id: fontLoader
        source: "assets/font/font.ttf"
    }

    Item {
        anchors.fill: parent
        Rectangle {
            id: conteinerAll
            anchors.fill: parent
            color: "#0e0e0e"
            opacity: 1.0
            visible: true;
            
            Rectangle {
                id: conteiner
                anchors.centerIn: parent
                width: parent.width * 0.98
                height: parent.height * 0.80
                color:  "#0e0e0e"
                opacity: 1.0
                visible: true;
                    
                ListView {
                    id: listView
                    width: parent.width / 4
                    height: parent.height
                    anchors.left: parent.left
                    clip: true
                    model: api.collections
                    focus: true
                    property string currentShortName: ""
                    property string currentName: ""
                    property int maxVisibleItems: Math.floor(height / 40)
                    property int midIndex: Math.floor(maxVisibleItems / 2)
                    property int adjustedIndex: Math.max(0, currentIndex - midIndex)

                    delegate: Rectangle {
                        width: listView.width
                        height: 40
                        color: listView.currentIndex === index && listView.focus ? "#303030" : "transparent"
                        border.width: 2
                        border.color: listView.currentIndex === index && listView.focus ? "#303030" : "transparent"
                        Row {
                            id: contentRow
                            anchors.centerIn: parent
                            spacing: 10
                            width: listView.focus ? parent.width : 40
                            Rectangle {
                                width: 0.5
                                height: parent.height
                                color: "transparent"
                            }
                            
                            Image {
                                source: "assets/systems/" + modelData.shortName + ".png"
                                width: 40
                                height: 40
                                fillMode: Image.PreserveAspectFit
                                anchors.verticalCenter: parent.verticalCenter
                                sourceSize { width: 40; height: 40 }
                            }
                            
                            Text {
                                visible: listView.focus
                                text: modelData.name
                                font.pixelSize: Math.min(listView.height * 0.03, listView.width / 20)
                                elide: listView.focus ? Text.ElideRight : Text.ElideNone
                                color: "#c0c0c0"
                                anchors.verticalCenter: parent.verticalCenter
                                font.family: fontLoader.name
                                width: listView.focus ? Math.max(0, listView.width - 10 - 30 - 20) : 30
                            }
                        }
                    }
                    Behavior on width {
                        NumberAnimation {
                            duration: 300
                            easing.type: Easing.InOutQuad
                        }
                    }
                    Keys.onUpPressed: {
                        if (currentIndex > 0) {
                            decrementCurrentIndex()
                        }
                    }
                    Keys.onDownPressed: {
                        if (currentIndex < count - 1) {
                            incrementCurrentIndex()
                        }
                    }
                    Keys.onRightPressed: {
                        listView.width = parent.width / 8
                        gameListView.focus = true
                        gameListView.currentIndex = 0
                    }
                    onCurrentIndexChanged: {
                        const selectedCollection = api.collections.get(currentIndex)
                        gameListView.model = selectedCollection.games
                        currentShortName = selectedCollection.shortName
                        currentName = selectedCollection.name
                        
                        if (currentIndex > midIndex && currentIndex < count - midIndex) {
                            contentY = adjustedIndex * 40
                        } else if (currentIndex <= midIndex) {
                            contentY = 0
                        } else {
                            contentY = (count - maxVisibleItems) * 40
                        }
                    }
                }

                ListView {
                    id: gameListView
                    width: parent.width / 2
                    height: parent.height
                    anchors.left: listView.right
                    clip: true

                    property int indexToPosition: -1

                    delegate: Rectangle {
                        width: gameListView.width
                        height: 50
                        color: gameListView.currentIndex === index && gameListView.focus ? "#303030" : "transparent"
                        border.width: 2
                        border.color: gameListView.currentIndex === index && gameListView.focus ? "#303030" : "transparent"
                        clip: true

                        Row {
                            id: contentRow1
                            anchors.centerIn: parent
                            spacing: 10

                            Rectangle {
                                width: 20.0
                                height: parent.height
                                color: "transparent"
                            }

                            Image {
                                source: "assets/systems/" + listView.currentShortName + "-content.png"
                                width: 30
                                height: 30
                                fillMode: Image.PreserveAspectFit
                                anchors.verticalCenter: parent.verticalCenter
                                sourceSize { width: 30; height: 30 }
                            }

                            Text {
                                id: gameText
                                width: gameListView.width - 40
                                elide: Text.ElideRight
                                text: modelData.title
                                font.pixelSize: Math.min(gameListView.height *0.03, gameListView.width / 20)
                                font.family: fontLoader.name
                                color: "#c0c0c0"
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                    }

                    focus: false

                    Keys.onLeftPressed: {
                        listView.width = parent.width / 4
                        listView.focus = true
                    }

                    Keys.onUpPressed: {
                        if (gameListView.currentIndex === 0) {
                            gameListView.currentIndex = gameListView.count - 1;
                        } else {
                            gameListView.currentIndex -= 1;
                        }
                    }

                    Keys.onDownPressed: {
                        if (gameListView.currentIndex === gameListView.count - 1) {
                            gameListView.currentIndex = 0;
                        } else {
                            gameListView.currentIndex += 1;
                        }
                    }
                    
                    Keys.onPressed: {
                        if (!event.isAutoRepeat && api.keys.isAccept(event)) {
                            var game = gameListView.model.get(gameListView.currentIndex);
                            game.launch();
                        }
                    }


                    onFocusChanged: {
                        if (gameListView.focus && gameListView.count > 0) {
                            infogame.selectedGame = gameListView.model.get(gameListView.currentIndex)
                        }
                    }

                    onCurrentItemChanged: {
                        if (gameListView.focus) {
                            infogame.selectedGame = model.get(currentIndex)
                            indexToPosition = currentIndex
                            updatePlayTime(); 
                        }
                    }

                    onIndexToPositionChanged: {
                        if (indexToPosition >= 0) {
                            positionViewAtIndex(indexToPosition, ListView.Center)
                        }
                    }

                    Behavior on indexToPosition {
                        NumberAnimation { duration: 200 }
                    }
                }

                Rectangle {
                    id: infogame
                    color: "transparent"
                    width: parent.width - listView.width - gameListView.width
                    height: parent.height
                    anchors.left: gameListView.right
                    property var selectedGame: null

                    Behavior on width {
                        NumberAnimation {
                            duration: 300
                            easing.type: Easing.InOutQuad
                        }
                    }

                    onVisibleChanged: {
                        if (!visible) {
                            selectedGame = null;
                        }
                    }

                    Item {
                        anchors.fill: parent

                        Image {
                            id: pegasusTitle
                            anchors.topMargin: 10
                            anchors.top: parent.top
                            anchors.horizontalCenter: parent.horizontalCenter
                            source: "assets/theme-icons/pegasus-title.png"
                            fillMode: Image.PreserveAspectFit
                            width: parent.width * 0.85
                            height: parent.height * 0.40
                            visible: listView.focus
                            sourceSize { width: 356; height: 356 }
                        }

                        Item {
                            id: boxFrontContainer
                            anchors.topMargin: 10
                            anchors.top: parent.top
                            anchors.horizontalCenter: parent.horizontalCenter
                            width: parent.width * 0.85
                            height: parent.height * 0.40
                            visible: !listView.focus

                            Image {
                                id: boxFrontImage
                                anchors.fill: parent
                                source: infogame.selectedGame ? infogame.selectedGame.assets.boxFront : ""
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
                                sourceSize { width: 200; height:200 }
                                visible: boxFrontImage.status !== Image.Ready
                            }
                        }

                        Column {
                            anchors.bottom: parent.bottom
                            anchors.left: parent.left
                            anchors.leftMargin: 20
                            spacing: 10
                            anchors.bottomMargin: 40
                            width: parent.width - 40

                            Text {
                                text: "Games:\n" + (gameListView.count > 0 ? (gameListView.currentIndex + 1) + "/" + gameListView.count : "0/0")
                                font.pixelSize: Math.min(infogame.height / 28, infogame.width / 2)
                                color: "#c0c0c0"
                                width: parent.width
                                wrapMode: Text.Wrap
                            }

                            Text {
                                id: collectionText
                                text: "Collection:\n" + (api.collections.get(listView.currentIndex) ? api.collections.get(listView.currentIndex).shortName : "None")
                                font.pixelSize: Math.min(infogame.height / 28, infogame.width / 2)
                                color: "#c0c0c0"
                                width: parent.width
                                wrapMode: Text.Wrap
                            }

                            Text {
                                id: playTimeText
                                text: "Play Time:"
                                font.pixelSize: Math.min(infogame.height / 28, infogame.width / 2)
                                color: "#c0c0c0"
                                width: parent.width
                                wrapMode: Text.Wrap
                            }

                            Text {
                                id: lastPlayedText
                                text: "Last Played:\n" + (infogame.selectedGame ? infogame.selectedGame.lastPlayed : "N/A")
                                font.pixelSize: Math.min(infogame.height / 28, infogame.width / 2)
                                color: "#c0c0c0"
                                width: parent.width
                                wrapMode: Text.Wrap
                            }
                        }
                    }
                }
            }

            Rectangle {
                id: topBar
                height: parent.height * 0.10    
                width: parent.width * 0.98
                anchors.horizontalCenter: parent.horizontalCenter        
                anchors.bottom: conteiner.top 
                color: "#0e0e0e"

                Row {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    spacing: 10 
                    
                    Image {
                        source: "assets/theme-icons/pegasus.png"
                        width: 40
                        height: 40
                        anchors.verticalCenter: parent.verticalCenter
                        sourceSize { width: 76; height: 76 }
                    }

                    Text {
                        text: listView.currentName
                        color: "white"
                        font.bold: true
                        font.family: fontLoader.name
                        font.pixelSize: Math.min(topBar.height / 2, topBar.width / 40)
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                Row {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    spacing: 10

                    Row {
                        spacing: 5
                        Text {
                            text: Qt.formatDateTime(new Date(), "dd-MM HH:mm")
                            color: "white"
                            font.pixelSize: Math.min(topBar.height / 3, topBar.width / 40)
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Image {
                            source: "assets/theme-icons/clock.png"
                            width: 20
                            height: 20 
                            anchors.verticalCenter: parent.verticalCenter
                            sourceSize { width: 20; height: 20 }
                        }
                    }
                    
                    Row {
                        spacing: 5
                        Text {
                            text: {
                                if (isNaN(api.device.batteryPercent)) {
                                    return "N/A"
                                } else {
                                    return (api.device.batteryPercent * 100).toFixed(0) + "%"
                                }
                            }
                            color: "white"
                            font.pixelSize: Math.min(topBar.height / 3, topBar.width / 40)
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Image {
                            source: "assets/theme-icons/battery.png"
                            width: 20 
                            height: 20 
                            anchors.verticalCenter: parent.verticalCenter
                            sourceSize { width: 20; height: 20 }
                        }
                    }
                }
            }

            Rectangle {
                id: bottomBar
                height: parent.height * 0.10
                width: parent.width * 0.98
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: conteiner.bottom 
                color: "#0e0e0e"

                Row {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    spacing: 20

                    Row {
                        spacing: 5 
                        Image {
                            source: "assets/theme-icons/back.png"
                            width: Math.min(parent.height * 0.95, parent.width * 0.95)
                            height: Math.min(parent.height * 0.95, parent.width * 0.95) 
                            anchors.verticalCenter: parent.verticalCenter
                            sourceSize { width: 64; height: 64 }
                        }

                        Text {
                            text: " Back"
                            color: "white"
                            font.family: fontLoader.name
                            font.pixelSize: Math.min(bottomBar.height / 3, bottomBar.width / 40)
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    Row {
                        spacing: 5
                        Image {
                            source: "assets/theme-icons/ok.png"
                            width: Math.min(parent.height * 0.95, parent.width * 0.95)
                            height: Math.min(parent.height * 0.95, parent.width * 0.95)
                            anchors.verticalCenter: parent.verticalCenter
                            sourceSize { width: 64; height: 64 }
                        }

                        Text {
                            text: " OK"
                            color: "white"
                            font.family: fontLoader.name
                            font.pixelSize: Math.min(bottomBar.height / 3, bottomBar.width / 40)
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                }
            }
        }
    }

    function updatePlayTime() {
        var game = gameListView.model.get(gameListView.currentIndex);
        if (game) {
            
            var totalSeconds = game.playTime || 0;
            
            var hours = Math.floor(totalSeconds / 3600);
            var minutes = Math.floor((totalSeconds % 3600) / 60);
            var seconds = totalSeconds % 60;
            var playTimeFormatted = 
                (hours < 10 ? "0" : "") + hours + ":" + 
                (minutes < 10 ? "0" : "") + minutes + ":" + 
                (seconds < 10 ? "0" : "") + seconds;

            playTimeText.text = "Play Time:\n" + playTimeFormatted;
        } else {
            
            playTimeText.text = "Play Time: 00:00:00\n";
        }
    }
}

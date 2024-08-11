// Pegasus Frontend - Flat Ozone
// Author: Gonzalo Abbate 
// GNU/LINUX - WINDOWS
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program. If not, see <http://www.gnu.org/licenses/>.

import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.12
import SortFilterProxyModel 0.2
import QtMultimedia 5.8

FocusScope {
    focus: true

    property string collectionShortName: ""
    
    function showNotification(message) {
        notificationText.text = message
        notification.visible = true
        notification.opacity = 1
        hideNotificationTimer.start()
    }

    FontLoader {
        id: fontLoader
        source: "assets/font/font.ttf"
    }

    Item {
        id: collectionsItem
        property alias favoritesModel: favoritesProxyModel
        property alias historyModel: continuePlayingProxyModel

        ListModel {
            id: collectionsModel
            property int favoritesIndex: -1
            property int historyIndex : - 1
            Component.onCompleted: {
                var favoritecollection = { name: "Favorite", shortName: "favorite", games: favoritesProxyModel };
                collectionsModel.append(favoritecollection);
                collectionsModel.favoritesIndex = collectionsModel.count - 1;

                var historycollection = { name: "History", shortName: "history", games: continuePlayingProxyModel };
                collectionsModel.append(historycollection);
                collectionsModel.historyIndex = collectionsModel.count - 1;

                for (var i = 0; i < api.collections.count; ++i) {
                    var collection = api.collections.get(i);
                        collectionsModel.append(collection);
                }
            }
        }

        SortFilterProxyModel {
            id: favoritesProxyModel
            sourceModel: api.allGames
            filters: ValueFilter { roleName: "favorite"; value: true }
        }

        SortFilterProxyModel {
            id: historyProxyModel
            sourceModel: api.allGames
            sorters: RoleSorter { roleName: "lastPlayed"; sortOrder: Qt.DescendingOrder }
        }

        ListModel {
            id: continuePlayingProxyModel
            Component.onCompleted: {
                var currentDate = new Date()
                var sevenDaysAgo = new Date(currentDate.getTime() - 7 * 24 * 60 * 60 * 1000)
                for (var i = 0; i < historyProxyModel.count; ++i) {
                    var game = historyProxyModel.get(i)
                    var lastPlayedDate = new Date(game.lastPlayed)
                    var playTimeInMinutes = game.playTime / 60
                    if (lastPlayedDate >= sevenDaysAgo && playTimeInMinutes > 1) {
                        continuePlayingProxyModel.append(game)
                    }
                }
            }
        }
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
                opacity: 1
                visible: true;

                Rectangle {
                    id: notification
                    width: 350
                    height: 50
                    color: "#303030"
                    visible: false
                    opacity: 1
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.leftMargin: 2
                    z: 1
                    
                    Row {
                        spacing: 10
                        anchors.centerIn: parent

                        Image {
                            source: "assets/theme-icons/info.png"
                            anchors.verticalCenter: parent.verticalCenter
                            width: 24
                            height: 24
                            sourceSize { width: 30; height: 30 }
                        }

                        Text {
                            id: notificationText
                            text: ""
                            color: "#ffffff"
                            font.family: fontLoader.name
                            font.pixelSize: 24
                            verticalAlignment: Text.AlignVCenter
                        }
                    }

                    Behavior on opacity {
                        NumberAnimation {
                            duration: 300
                            easing.type: Easing.InOutQuad
                        }
                    }
                }

                Timer {
                    id: hideNotificationTimer
                    interval: 3000
                    running: false
                    repeat: false
                    onTriggered: {
                        notification.opacity = 1
                        notification.visible = false
                    }
                }

                ListView {
                    id: listView
                    width: parent.width / 4
                    height: parent.height
                    anchors.left: parent.left
                    clip: true
                    model: collectionsModel
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
                                source: "assets/systems/" + model.shortName + ".png"
                                width: 40
                                height: 40
                                fillMode: Image.PreserveAspectFit
                                anchors.verticalCenter: parent.verticalCenter
                                sourceSize { width: 40; height: 40 }
                            }
                            
                            Text {
                                visible: listView.focus
                                text: model.name
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
                        const selectedCollection = collectionsModel.get(currentIndex)
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
                                id: systemIcono
                                source: "assets/systems/" + getShortNameForGame(model) + "-content.png"
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
                                text: model.title
                                font.pixelSize: Math.min(gameListView.height * 0.03, gameListView.width / 20)
                                font.family: fontLoader.name
                                color: "#c0c0c0"
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        function getShortNameForGame(game) {
                            if (game && game.collections && game.collections.count > 0) {
                                var firstCollection = game.collections.get(0);
                                for (var i = 0; i < api.collections.count; ++i) {
                                    var collection = api.collections.get(i);
                                    if (collection.name === firstCollection.name) {
                                        return collection.shortName;
                                    }
                                }
                            }
                            return "default"; 
                        }
                    }

                    Row {
                        anchors.centerIn: parent
                        spacing: 5 
                        visible: gameListView.count === 0

                        Image {
                            source: "assets/theme-icons/info2.png"
                            width: 64
                            height: 64
                            anchors.verticalCenter: parent.verticalCenter
                            sourceSize { width: 64; height: 64 }
                        }

                        Text {
                            id: noGamesText
                            text: "No " + listView.currentName + " Available"
                            font.pixelSize: 20
                            color: "#ffffff"
                            anchors.verticalCenter: parent.verticalCenter
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
                            var selectedGame = gameListView.model.get(gameListView.currentIndex);
                            var selectedTitle = selectedGame.title;
                            var gamesArray = api.allGames.toVarArray();
                            var gameFound = gamesArray.find(function(game) {
                                return game.title === selectedTitle;
                            });
                            if (gameFound) {
                                gameFound.launch();
                            }
                        } else if (api.keys.isDetails(event)) {
                            event.accepted = true;
                            var selectedGame = gameListView.model.get(gameListView.currentIndex);
                            var selectedTitle = selectedGame.title;
                            var gamesArray = api.allGames.toVarArray();
                            var gameFound = gamesArray.find(function(game) {
                                return game.title === selectedTitle;
                            });
                            if (gameFound) {
                                var wasFavorite = gameFound.favorite;
                                gameFound.favorite = !wasFavorite;
                            
                                var notificationMessage = wasFavorite ? "Removed from favorites" : "Added to favorites";
                                showNotification(notificationMessage);

                                if (gameListView.count === 0) {
                                    infogame.selectedGame = null;
                                }
                            }
                        }
                    }
                    
                    onFocusChanged: {
                        if (gameListView.focus && gameListView.count > 0) {
                            infogame.selectedGame = gameListView.model.get(gameListView.currentIndex);
                            /*updatePlayTime();
                            updateLastPlayed();*/
                            updateGameInfo();
                        } else {
                            infogame.selectedGame = null;
                        }
                    }

                    onCurrentItemChanged: {
                        if (gameListView.count > 0 && gameListView.focus) {
                            infogame.selectedGame = gameListView.model.get(gameListView.currentIndex);
                            indexToPosition = currentIndex;
                            /*updatePlayTime();
                            updateLastPlayed();*/
                            updateGameInfo();
                        } else {
                            infogame.selectedGame = null;
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
                            id: infoText
                            anchors.bottom: parent.bottom
                            anchors.left: parent.left
                            anchors.leftMargin: 20
                            spacing: 10
                            anchors.bottomMargin: 30
                            width: parent.width - 40

                            Text {
                                text: "Games:\n" + (gameListView.count > 0 ? (gameListView.currentIndex + 1) + "/" + gameListView.count : "0/0")
                                font.pixelSize: Math.min(infogame.height / 28, infogame.width / 18)
                                color: "#c0c0c0"
                                width: parent.width
                                wrapMode: Text.Wrap
                            }

                            Text {
                                id: collectionText
                                text: "Collection:\n" + (collectionsModel.get(listView.currentIndex) ? collectionsModel.get(listView.currentIndex).shortName : "None")
                                font.pixelSize: Math.min(infogame.height / 28, infogame.width / 18)
                                color: "#c0c0c0"
                                width: parent.width
                                wrapMode: Text.Wrap
                            }

                            Text {
                                id: playTimeText
                                text: "Play Time:"
                                font.pixelSize: Math.min(infogame.height / 28, infogame.width / 18)
                                color: "#c0c0c0"
                                width: parent.width
                                wrapMode: Text.Wrap
                            }

                            Text {
                                id: lastPlayedText
                                text: "Last Played:"
                                font.pixelSize: Math.min(infogame.height / 28, infogame.width / 18)
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
                            source: "assets/theme-icons/favorite.png"
                            width: Math.min(parent.height * 0.95, parent.width * 0.95)
                            height: Math.min(parent.height * 0.95, parent.width * 0.95) 
                            anchors.verticalCenter: parent.verticalCenter
                            sourceSize { width: 64; height: 64 }
                        }

                        Text {
                            text: " Favorite"
                            color: "white"
                            font.family: fontLoader.name
                            font.pixelSize: Math.min(bottomBar.height / 3, bottomBar.width / 40)
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

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

    function updateGameInfo() {
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

            if (game.lastPlayed.getTime()) {
                var lastPlayedDate = new Date(game.lastPlayed);
                var formattedDate = Qt.formatDateTime(lastPlayedDate, "yyyy-MM-dd HH:mm");
                lastPlayedText.text = "Last Played:\n" + formattedDate;
            } else {
                lastPlayedText.text = "Last Played:\nN/A";
            }
        } else {
            playTimeText.text = "Play Time: 00:00:00\n";
            lastPlayedText.text = "Last Played:\nN/A";
        }
    }
}

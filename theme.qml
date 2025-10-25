import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.12
import SortFilterProxyModel 0.2
import QtMultimedia 5.15

FocusScope {
    id: root
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

    SoundEffect {
        id: up
        source: "assets/sound/up.wav"
        volume: 2.5
    }

    SoundEffect {
        id: down
        source: "assets/sound/down.wav"
        volume: 2.5
    }

    SoundEffect {
        id: favo
        source: "assets/sound/favo.wav"
        volume: 2.5
    }

    Audio {
        id: bgm
        source: "assets/sound/bgm.ogg"
        loops: Audio.Infinite
        volume: 1
        autoPlay: true
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
                            smooth: true
                            sourceSize { width: 40; height: 40 }
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
                    property int itemHeight: 40
                    property int visibleItemCount: Math.floor(height / itemHeight)
                    property int indexToPosition: -1

                    delegate: Column {
                        width: listView.width

                        Rectangle {
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
                                    mipmap: true
                                }

                                Text {
                                    visible: listView.focus
                                    text: model.name
                                    font.pixelSize: root.width * 0.012
                                    elide: listView.focus ? Text.ElideRight : Text.ElideNone
                                    color: (listView.currentIndex === index && listView.focus) ? "#ffffff" : "#c0c0c0"
                                    anchors.verticalCenter: parent.verticalCenter
                                    font.family: fontLoader.name
                                    font.bold: false
                                    width: listView.focus ? Math.max(0, listView.width - 10 - 30 - 20) : 30
                                }
                            }
                        }


                        Rectangle {
                            width: parent.width * 0.90
                            height: 1
                            color: "#2c2c2c"
                            opacity: 0.5
                            visible: index === 1
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
                            currentIndex--
                        } else {
                            currentIndex = count - 1
                        }
                        up.play()
                    }

                    Keys.onDownPressed: {
                        if (currentIndex < count - 1) {
                            currentIndex++
                        } else {
                            currentIndex = 0
                        }
                        down.play()
                    }

                    Keys.onRightPressed: {
                        listView.width = parent.width / 8
                        gameListView.focus = true
                        gameListView.currentIndex = 0
                        up.play()
                    }

                    onCurrentIndexChanged: {
                        const selectedCollection = collectionsModel.get(currentIndex)
                        gameListView.model = selectedCollection.games
                        currentShortName = selectedCollection.shortName
                        currentName = selectedCollection.name
                        indexToPosition = currentIndex
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
                                width: root.width * 0.045
                                height: root.height * 0.045
                                fillMode: Image.PreserveAspectFit
                                anchors.verticalCenter: parent.verticalCenter
                                mipmap: true
                            }

                            Text {
                                id: gameText
                                width: gameListView.width - 40
                                elide: Text.ElideRight
                                text: model.title
                                font.pixelSize: root.width * 0.012
                                font.family: fontLoader.name
                                color: "#c0c0c0"
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        Rectangle {
                            width: parent.width
                            height: 1
                            color: "#2c2c2c"
                            opacity: 0.4
                            visible: index !== gameListView.count - 1
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
                        clearGameInfo();
                        down.play()
                    }

                    Keys.onUpPressed: {
                        if (gameListView.currentIndex === 0) {
                            gameListView.currentIndex = gameListView.count - 1;
                        } else {
                            gameListView.currentIndex -= 1;
                        }
                        up.play()
                    }

                    Keys.onDownPressed: {
                        if (gameListView.currentIndex === gameListView.count - 1) {
                            gameListView.currentIndex = 0;
                        } else {
                            gameListView.currentIndex += 1;
                        }
                        down.play()
                    }

                    Keys.onPressed: {
                        if (!event.isAutoRepeat && api.keys.isAccept(event)) {
                            event.accepted = true;
                            var selectedGame = gameListView.model.get(gameListView.currentIndex);
                            var collectionName = getNameCollecForGame(selectedGame);
                            for (var i = 0; i < api.collections.count; ++i) {
                                var collection = api.collections.get(i);
                                if (collection.name === collectionName) {
                                    for (var j = 0; j < collection.games.count; ++j) {
                                        var game = collection.games.get(j);
                                        if (game.title === selectedGame.title) {
                                            game.launch();
                                            break;
                                        }
                                    }
                                    break;
                                }
                            }
                        } else if (!event.isAutoRepeat && api.keys.isDetails(event)) {
                            event.accepted = true;
                            favo.play();
                            var selectedGame = gameListView.model.get(gameListView.currentIndex);
                            var collectionName = getNameCollecForGame(selectedGame);
                            var gameFound = null;
                            for (var i = 0; i < api.collections.count; ++i) {
                                var collection = api.collections.get(i);
                                if (collection.name === collectionName) {
                                    for (var j = 0; j < collection.games.count; ++j) {
                                        var game = collection.games.get(j);
                                        if (game.title === selectedGame.title) {
                                            gameFound = game;
                                            game.favorite = !game.favorite;
                                            favoriteText.text = "Favorite: " + (game.favorite ? "Yes" : "No");
                                            updateContinuePlayingModel();
                                            var notificationMessage = game.favorite ? "Added to favorites" : "Removed from favorites";
                                            showNotification(notificationMessage);
                                            break;
                                        }
                                    }
                                    break;
                                }
                            }

                            if (gameListView.count === 0) {
                                infogame.selectedGame = null;
                            }
                        } else if (!event.isAutoRepeat && api.keys.isFilters(event)) {
                            event.accepted = true;
                            // Cambiar entre 'boxFront' y 'screenshot'
                            if (infogame.currentImageType === "boxFront") {
                                infogame.currentImageType = "screenshot";
                            } else {
                                infogame.currentImageType = "boxFront";
                            }
                        } else if (!event.isAutoRepeat && api.keys.isCancel(event)) {
                            event.accepted = true;
                            listView.width = parent.width / 4
                            listView.focus = true
                            clearGameInfo();
                            down.play()
                        }
                    }
                    
                    onCurrentItemChanged: {
                        if (gameListView.count > 0 && gameListView.focus) {
                            infogame.selectedGame = gameListView.model.get(gameListView.currentIndex);
                            indexToPosition = currentIndex;
                            updateGameInfo();
                        } else {
                            infogame.selectedGame = null;
                        }
                    }

                    onFocusChanged: {
                        if (gameListView.focus && gameListView.count > 0) {
                            infogame.selectedGame = gameListView.model.get(gameListView.currentIndex);
                            updateGameInfo();
                        } else {
                            infogame.selectedGame = null;
                            // Limpiar los textos cuando se pierde el foco
                            clearGameInfo();
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
                    property string currentImageType: "boxFront"

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
                                source: infogame.selectedGame ? infogame.selectedGame.assets[infogame.currentImageType] : ""
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

                            Text {
                                id: favoriteText
                                text: "Favorite: "
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
                        width: 50
                        height: 50
                        mipmap: true
                        anchors.verticalCenter: parent.verticalCenter
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
                        id: clockRow
                        spacing: 5

                        Timer {
                            id: clockTimer
                            interval: 1000
                            repeat: true
                            running: true

                            onTriggered: {
                                clockText.text = Qt.formatDateTime(new Date(), "dd-MM HH:mm")
                            }
                        }

                        Text {
                            id: clockText
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

                        function getBatteryIcon() {
                            if (isNaN(api.device.batteryPercent)) {
                                return "assets/theme-icons/battery.png";
                            }

                            const batteryPercent = api.device.batteryPercent * 100;

                            if (api.device.batteryCharging) {
                                return "assets/theme-icons/charging.png";
                            }

                            if (batteryPercent <= 20) {
                                return "assets/theme-icons/20.png";
                            } else if (batteryPercent <= 40) {
                                return "assets/theme-icons/40.png";
                            } else if (batteryPercent <= 60) {
                                return "assets/theme-icons/60.png";
                            } else if (batteryPercent <= 80) {
                                return "assets/theme-icons/80.png";
                            } else {
                                return "assets/theme-icons/battery.png";
                            }
                        }

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
                            source: parent.getBatteryIcon()
                            width: root.width * 0.014
                            height: root.height * 0.034
                            anchors.verticalCenter: parent.verticalCenter
                            mipmap: true
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
                    id: mainRow
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    spacing: 20

                    Behavior on anchors.rightMargin {
                        NumberAnimation {
                            duration: 300
                            easing.type: Easing.InOutQuad
                        }
                    }

                    Row {
                        id: detailsRow
                        spacing: 5
                        visible: gameListView.focus
                        opacity: gameListView.focus ? 1.0 : 0.0

                        Behavior on opacity {
                            NumberAnimation {
                                duration: 300
                                easing.type: Easing.InOutQuad
                            }
                        }

                        onOpacityChanged: {
                            if (opacity === 0.0) {
                                visible = false;
                            } else {
                                visible = true;
                            }
                        }

                        Image {
                            source: "assets/theme-icons/details.png"
                            width: bottomBar.width * 0.02
                            height: bottomBar.height * 0.35
                            anchors.verticalCenter: parent.verticalCenter
                            sourceSize { width: 64; height: 64 }
                        }

                        Text {
                            text: " Cycle thumbnail"
                            color: "white"
                            font.family: fontLoader.name
                            font.pixelSize: bottomBar.height * 0.25
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    Row {
                        id: favoriteRow
                        spacing: 5
                        visible: gameListView.focus
                        opacity: gameListView.focus ? 1.0 : 0.0

                        Behavior on opacity {
                            NumberAnimation {
                                duration: 300
                                easing.type: Easing.InOutQuad
                            }
                        }

                        onOpacityChanged: {
                            if (opacity === 0.0) {
                                visible = false;
                            } else {
                                visible = true;
                            }
                        }

                        Image {
                            source: "assets/theme-icons/favorite.png"
                            width: bottomBar.width * 0.02
                            height: bottomBar.height * 0.35
                            anchors.verticalCenter: parent.verticalCenter
                            sourceSize { width: 64; height: 64 }
                        }

                        Text {
                            text: " Favorite"
                            color: "white"
                            font.family: fontLoader.name
                            font.pixelSize: bottomBar.height * 0.25
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }


                    Row {
                        id: okRow
                        spacing: 5
                        visible: gameListView.focus
                        opacity: gameListView.focus ? 1.0 : 0.0

                        Behavior on opacity {
                            NumberAnimation {
                                duration: 300
                                easing.type: Easing.InOutQuad
                            }
                        }

                        onOpacityChanged: {
                            if (opacity === 0.0) {
                                visible = false;
                            } else {
                                visible = true;
                            }
                        }

                        Image {
                            source: "assets/theme-icons/ok.png"
                            width: bottomBar.width * 0.02
                            height: bottomBar.height * 0.35
                            anchors.verticalCenter: parent.verticalCenter
                            sourceSize { width: 64; height: 64 }
                        }

                        Text {
                            text: " OK"
                            color: "white"
                            font.family: fontLoader.name
                            font.pixelSize: bottomBar.height * 0.25
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    Row {
                        id: backRow
                        spacing: 5
                        Image {
                            source: "assets/theme-icons/back.png"
                            width: bottomBar.width * 0.02
                            height: bottomBar.height * 0.35
                            anchors.verticalCenter: parent.verticalCenter
                            sourceSize { width: 64; height: 64 }
                        }

                        Text {
                            text: " Back"
                            color: "white"
                            font.family: fontLoader.name
                            font.pixelSize: bottomBar.height * 0.25
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                }

                states: [
                    State {
                        name: "hidden"
                        when: !gameListView.focus
                        PropertyChanges {
                            target: mainRow
                            anchors.rightMargin: backRow.width + bottomBar.width * 0.003
                        }
                    },
                    State {
                        name: "visible"
                        when: gameListView.focus
                        PropertyChanges {
                            target: mainRow
                            anchors.rightMargin: 0
                        }
                    }
                ]
            }
        }
    }

    function clearGameInfo() {
        playTimeText.text = "Play Time:";
        lastPlayedText.text = "Last Played:";
        favoriteText.text = "Favorite:";
    }
    function updateGameInfo() {
        if (!gameListView.focus) {
            clearGameInfo();
            return;
        }

        var game = gameListView.model.get(gameListView.currentIndex);
        if (!game) {
            clearGameInfo();
            return;
        }

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

        var collectionName = getNameCollecForGame(game);
        for (var i = 0; i < api.collections.count; ++i) {
            var collection = api.collections.get(i);
            if (collection.name === collectionName) {
                for (var j = 0; j < collection.games.count; ++j) {
                    var originalGame = collection.games.get(j);
                    if (originalGame.title === game.title) {
                        favoriteText.text = "Favorite: " + (originalGame.favorite ? "Yes" : "No");
                        break;
                    }
                }
                break;
            }
        }
    }
    function getNameCollecForGame(game) {
        if (game && game.collections && game.collections.count > 0) {
            var firstCollection = game.collections.get(0);
            for (var i = 0; i < api.collections.count; ++i) {
                var collection = api.collections.get(i);
                if (collection.name === firstCollection.name) {
                    return collection.name;
                }
            }
        }
        return "default";
    }
    function updateContinuePlayingModel() {
        continuePlayingProxyModel.clear();

        var currentDate = new Date();
        var sevenDaysAgo = new Date(currentDate.getTime() - 7 * 24 * 60 * 60 * 1000);

        for (var i = 0; i < historyProxyModel.count; ++i) {
            var game = historyProxyModel.get(i);
            var lastPlayedDate = new Date(game.lastPlayed);
            var playTimeInMinutes = game.playTime / 60;

            if (lastPlayedDate >= sevenDaysAgo && playTimeInMinutes > 1) {
                continuePlayingProxyModel.append(game);
            }
        }
    }
}

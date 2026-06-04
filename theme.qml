import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.12
import SortFilterProxyModel 0.2
import QtMultimedia 5.15
import "utils.js" as Utils

FocusScope {
    id: root
    focus: true

    FontLoader {
        id: fontLoader
        source: "assets/font/font.ttf"
    }

    ThemeSettings {
        id: themeSettings
    }

    SoundManager {
        id: soundManager
    }

    CollectionsData {
        id: collectionsData
    }

    property string activePanel: "games"

    function clearGameInfo() {
        infoPanel.playTimeDisplay = "Play Time:";
        infoPanel.lastPlayedDisplay = "Last Played:";
        infoPanel.favoriteDisplay = "Favorite:";
    }

    property var imageAssetTypes: [
        "boxFront", "screenshot", "boxBack", "logo", "titlescreen",
        "marquee", "poster", "steam", "banner", "tile", "cartridge",
        "boxSpine", "boxFull", "bezel", "panel", "cabinetLeft",
        "cabinetRight", "background"
    ]

    function getFirstAvailableAssetType(game) {
        if (!game || !game.assets) return "boxFront"
            for (var i = 0; i < imageAssetTypes.length; ++i) {
                var type = imageAssetTypes[i]
                var assetUrl = game.assets[type]
                if (assetUrl && assetUrl !== "") {
                    return type
                }
            }
            return "boxFront"
    }

    function getNextAvailableAssetType(game, currentType) {
        if (!game || !game.assets) return currentType
            var currentIndex = imageAssetTypes.indexOf(currentType)
            if (currentIndex === -1) currentIndex = 0

                for (var i = 1; i <= imageAssetTypes.length; ++i) {
                    var nextIndex = (currentIndex + i) % imageAssetTypes.length
                    var nextType = imageAssetTypes[nextIndex]
                    var assetUrl = game.assets[nextType]
                    if (assetUrl && assetUrl !== "") {
                        return nextType
                    }
                }
                return currentType
    }

    function updateGameInfo() {
        if (!gameListView.focus) { clearGameInfo(); return; }

        var game = gameListView.model.get(gameListView.currentIndex);
        if (!game) { clearGameInfo(); return; }

        if (infoPanel.selectedGame !== game) {
            infoPanel.currentImageType = getFirstAvailableAssetType(game)
        }

        infoPanel.selectedGame = game
        infoPanel.playTimeDisplay = "Play Time:\n" + Utils.formatPlayTime(game.playTime);

        if (game.lastPlayed.getTime()) {
            infoPanel.lastPlayedDisplay = "Last Played:\n" +
            Qt.formatDateTime(new Date(game.lastPlayed), "yyyy-MM-dd HH:mm");
        } else {
            infoPanel.lastPlayedDisplay = "Last Played:\nN/A";
        }

        var collectionName = Utils.getNameCollecForGame(game, api.collections);
        for (var i = 0; i < api.collections.count; ++i) {
            var col = api.collections.get(i);
            if (col.name === collectionName) {
                for (var j = 0; j < col.games.count; ++j) {
                    var orig = col.games.get(j);
                    if (orig.title === game.title) {
                        infoPanel.favoriteDisplay = "Favorite: " + (orig.favorite ? "Yes" : "No");
                        break;
                    }
                }
                break;
            }
        }
    }

    function launchGame(selectedGame) {
        var collectionName = Utils.getNameCollecForGame(selectedGame, api.collections);
        for (var i = 0; i < api.collections.count; ++i) {
            var col = api.collections.get(i);
            if (col.name === collectionName) {
                for (var j = 0; j < col.games.count; ++j) {
                    var game = col.games.get(j);
                    if (game.title === selectedGame.title) {
                        game.launch();
                        return;
                    }
                }
            }
        }
    }

    function toggleFavorite(selectedGame) {
        var collectionName = Utils.getNameCollecForGame(selectedGame, api.collections);
        for (var i = 0; i < api.collections.count; ++i) {
            var col = api.collections.get(i);
            if (col.name === collectionName) {
                for (var j = 0; j < col.games.count; ++j) {
                    var game = col.games.get(j);
                    if (game.title === selectedGame.title) {
                        game.favorite = !game.favorite;
                        infoPanel.favoriteDisplay = "Favorite: " + (game.favorite ? "Yes" : "No");
                        collectionsData.refreshContinuePlaying();
                        var msg = game.favorite ? "Added to favorites" : "Removed from favorites";
                        notification.show(msg);
                        if (gameListView.count === 0) infoPanel.selectedGame = null;
                        return;
                    }
                }
            }
        }
    }

    function enterSettings() {
        activePanel = "settings";
        settingsPanelItem.focus = true;
    }

    function leaveSettings() {
        collectionListView.focus = true;
        clearGameInfo();
        var sel = collectionsData.collectionsModel.get(collectionListView.currentIndex);
        activePanel = (sel && sel.isSettings) ? "settings" : "games";
    }

    Item {
        anchors.fill: parent

        Rectangle {
            id: containerAll
            anchors.fill: parent
            color: themeSettings.bgColor
            opacity: 1.0

            TopBar {
                id: topBar
                height: parent.height * 0.10
                width: parent.width * 0.98
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: container.top
                collectionName: collectionListView.currentName
                fontFamily: fontLoader.name
                themeSettings: themeSettings
            }

            Rectangle {
                id: container
                anchors.centerIn: parent
                width: parent.width * 0.98
                height: parent.height * 0.80
                color: themeSettings.bgColor

                NotificationBar {
                    id: notification
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.leftMargin: 2
                    fontFamily: fontLoader.name
                    themeSettings: themeSettings
                }

                CollectionListView {
                    id: collectionListView
                    width: parent.width / 4
                    height: parent.height
                    anchors.left: parent.left
                    model: collectionsData.collectionsModel
                    focus: true
                    fontFamily: fontLoader.name
                    sounds: soundManager
                    themeSettings: themeSettings

                    onCollectionSelected: function(gamesModel) {
                        if (root.activePanel === "settings") {
                            root.activePanel = "games";
                        }
                        gameListView.model = gamesModel;
                    }

                    onSettingsHighlighted: {
                        root.activePanel = "settings";
                    }

                    onNavigateRight: {
                        collectionListView.width = parent.width / 8;
                        gameListView.focus = true;
                        gameListView.currentIndex = 0;
                    }

                    onSettingsSelected: {
                        root.enterSettings();
                    }
                }

                GameListView {
                    id: gameListView
                    width: parent.width / 2
                    height: parent.height
                    anchors.left: collectionListView.right
                    fontFamily: fontLoader.name
                    currentCollectionName: collectionListView.currentName
                    sounds: soundManager
                    themeSettings: themeSettings
                    visible: root.activePanel === "games"

                    onNavigateLeft: {
                        collectionListView.width = parent.width / 4;
                        collectionListView.focus = true;
                        clearGameInfo();
                    }

                    onGameSelected: function(game) { launchGame(game); }
                    onFavoriteToggled: function(game) { toggleFavorite(game); }
                    onImageCycleRequested: {
                        var game = gameListView.model.get(gameListView.currentIndex)
                        if (game) {
                            var nextType = getNextAvailableAssetType(game, infoPanel.currentImageType)
                            if (nextType !== infoPanel.currentImageType) {
                                infoPanel.currentImageType = nextType
                            }
                        }
                    }
                    onGameInfoUpdateRequested: {
                        if (gameListView.focus && gameListView.count > 0) {
                            infoPanel.selectedGame = gameListView.model.get(gameListView.currentIndex);
                            updateGameInfo();
                        } else {
                            infoPanel.selectedGame = null;
                            clearGameInfo();
                        }
                    }
                }

                GameInfoPanel {
                    id: infoPanel
                    width: parent.width - collectionListView.width - gameListView.width
                    height: parent.height
                    anchors.left: gameListView.right
                    fontFamily: fontLoader.name
                    showLogo: collectionListView.focus
                    gameCount: gameListView.count
                    gameCurrentIndex: gameListView.currentIndex
                    themeSettings: themeSettings
                    collectionShortName: collectionsData.collectionsModel.get(collectionListView.currentIndex)
                    ? collectionsData.collectionsModel.get(collectionListView.currentIndex).shortName
                    : "None"
                    visible: root.activePanel === "games"
                }

                SettingsPanel {
                    id: settingsPanelItem
                    anchors.left: collectionListView.right
                    anchors.right: parent.right
                    height: parent.height
                    themeSettings: themeSettings
                    fontFamily: fontLoader.name
                    sounds: soundManager
                    soundManager: soundManager
                    visible: root.activePanel === "settings"
                    focus: root.activePanel === "settings"

                    onNavigateLeft: {
                        root.leaveSettings()
                    }
                }
            }

            BottomBar {
                id: bottomBar
                height: parent.height * 0.10
                width: parent.width * 0.98
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: container.bottom
                gameListFocused: gameListView.focus && root.activePanel === "games"
                settingsFocused: root.activePanel === "settings"
                _fontFamily: fontLoader.name
                themeSettings: themeSettings
            }
        }
    }

    Keys.onPressed: {
        if (event.isAutoRepeat) return;

        if (collectionListView.focus) {
            var selected = collectionsData.collectionsModel.get(collectionListView.currentIndex);
            if (selected && selected.isSettings && api.keys.isAccept(event)) {
                event.accepted = true;
                root.enterSettings();
                if (soundManager) soundManager.playUp();
            }
        }
    }
}

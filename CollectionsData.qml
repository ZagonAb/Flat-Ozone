import QtQuick 2.15
import SortFilterProxyModel 0.2
import "utils.js" as Utils

Item {
    id: collectionsData

    property alias collectionsModel: collectionsListModel
    property alias favoritesModel: favoritesProxyModel
    property alias historyModel: continuePlayingModel
    property int settingsIndex: -1

    function refreshContinuePlaying() {
        Utils.rebuildContinuePlaying(historyProxyModel, continuePlayingModel);
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
        id: continuePlayingModel
        Component.onCompleted: Utils.rebuildContinuePlaying(historyProxyModel, continuePlayingModel)
    }

    ListModel {
        id: collectionsListModel
        property int favoritesIndex: -1
        property int historyIndex: -1

        Component.onCompleted: {
            collectionsListModel.append({
                name: "Favorite",
                shortName: "favorite",
                games: favoritesProxyModel,
                isSettings: false
            });
            collectionsListModel.favoritesIndex = collectionsListModel.count - 1;

            collectionsListModel.append({
                name: "History",
                shortName: "history",
                games: continuePlayingModel,
                isSettings: false
            });
            collectionsListModel.historyIndex = collectionsListModel.count - 1;

            for (var i = 0; i < api.collections.count; ++i) {
                var col = api.collections.get(i);
                collectionsListModel.append({
                    name: col.name,
                    shortName: col.shortName,
                    games: col.games,
                    isSettings: false
                });
            }

            collectionsListModel.append({
                name: "Settings",
                shortName: "settings",
                games: null,
                isSettings: true
            });
            collectionsData.settingsIndex = collectionsListModel.count - 1;
        }
    }
}

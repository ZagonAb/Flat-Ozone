.pragma library

function getNameCollecForGame(game, apiCollections) {
    if (game && game.collections && game.collections.count > 0) {
        var firstCollection = game.collections.get(0);
        for (var i = 0; i < apiCollections.count; ++i) {
            var collection = apiCollections.get(i);
            if (collection.name === firstCollection.name) {
                return collection.name;
            }
        }
    }
    return "default";
}

function getShortNameForGame(game, apiCollections) {
    if (game && game.collections && game.collections.count > 0) {
        var firstCollection = game.collections.get(0);
        for (var i = 0; i < apiCollections.count; ++i) {
            var collection = apiCollections.get(i);
            if (collection.name === firstCollection.name) {
                return collection.shortName;
            }
        }
    }
    return "default";
}

function formatPlayTime(totalSeconds) {
    var s = totalSeconds || 0;
    var h = Math.floor(s / 3600);
    var m = Math.floor((s % 3600) / 60);
    var sec = s % 60;
    return (h < 10 ? "0" : "") + h + ":" +
    (m < 10 ? "0" : "") + m + ":" +
    (sec < 10 ? "0" : "") + sec;
}

function getBatteryIcon(batteryPercent, batteryCharging) {
    if (isNaN(batteryPercent)) {
        return "assets/theme-icons/battery.png";
    }
    var pct = batteryPercent * 100;
    if (batteryCharging) {
        return "assets/theme-icons/charging.png";
    }
    if (pct <= 20) return "assets/theme-icons/20.png";
    if (pct <= 40) return "assets/theme-icons/40.png";
    if (pct <= 60) return "assets/theme-icons/60.png";
    if (pct <= 80) return "assets/theme-icons/80.png";
    return "assets/theme-icons/battery.png";
}

function rebuildContinuePlaying(historyProxyModel, targetModel) {
    targetModel.clear();
    var now = new Date();
    var sevenAgo = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);
    for (var i = 0; i < historyProxyModel.count; ++i) {
        var game = historyProxyModel.get(i);
        var lastPlayedDate = new Date(game.lastPlayed);
        var playTimeMinutes = game.playTime / 60;
        if (lastPlayedDate >= sevenAgo && playTimeMinutes > 1) {
            targetModel.append(game);
        }
    }
}

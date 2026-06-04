import QtQuick 2.15
import QtMultimedia 5.15

Item {
    id: soundManager

    property bool bgmEnabled: true

    onBgmEnabledChanged: {
        if (bgmEnabled) {
            bgm.play()
        } else {
            bgm.stop()
        }
        api.memory.set("bgmEnabled", bgmEnabled)
    }

    function playUp() { up.play() }
    function playDown() { down.play() }
    function playFavo() { favo.play() }

    function toggleBgm() {
        bgmEnabled = !bgmEnabled
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
        volume: 1.0
        autoPlay: false

        onStatusChanged: {
            if (status === Audio.Loaded && bgmEnabled) {
                bgm.play()
            }
        }
    }

    Component.onCompleted: {
        var saved = api.memory.get("bgmEnabled")
        if (saved !== undefined && saved !== bgmEnabled) {
            bgmEnabled = saved
        }
    }
}

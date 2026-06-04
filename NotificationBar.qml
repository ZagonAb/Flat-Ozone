import QtQuick 2.15

Rectangle {
    id: notificationBar

    property alias fontFamily: notificationText.font.family
    property var themeSettings: null

    function show(message) {
        notificationText.text = message;
        notificationBar.visible = true;
        notificationBar.opacity = 1;
        hideTimer.restart();
    }

    width: 350
    height: 50
    color: themeSettings ? themeSettings.highlightColor : "#303030"
    radius: 4
    visible: false
    opacity: 1
    z: 1

    Rectangle {
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: 3
        radius: 2
        color: notificationBar.themeSettings ? notificationBar.themeSettings.accentColor : "#ffffff"
    }

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
            color: notificationBar.themeSettings ? notificationBar.themeSettings.textPrimary : "#ffffff"
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

    Timer {
        id: hideTimer
        interval: 3000
        repeat: false
        onTriggered: {
            notificationBar.opacity = 1;
            notificationBar.visible = false;
        }
    }
}

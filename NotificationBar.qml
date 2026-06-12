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

    width: vpx(350)
    height: vpx(50)
    color: themeSettings ? themeSettings.highlightColor : "#303030"
    radius: vpx(4)
    visible: false
    opacity: 1
    z: 1

    Rectangle {
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: vpx(3)
        radius: vpx(2)
        color: notificationBar.themeSettings ? notificationBar.themeSettings.accentColor : "#ffffff"
    }

    Row {
        spacing: vpx(10)
        anchors.centerIn: parent

        Image {
            source: "assets/theme-icons/info.png"
            anchors.verticalCenter: parent.verticalCenter
            width: vpx(24)
            height: vpx(24)
            smooth: true
            sourceSize { width: vpx(40); height: vpx(40) }
        }

        Text {
            id: notificationText
            text: ""
            color: notificationBar.themeSettings ? notificationBar.themeSettings.textPrimary : "#ffffff"
            font.pixelSize: vpx(24)
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

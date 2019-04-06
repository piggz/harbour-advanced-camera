import QtQuick 2.2
import Sailfish.Silica 1.0

Item {
    id: iconSwitch
    property string icon1Source: ""
    property string icon2Source: ""
    property string button1Name: ""
    property string button2Name: ""
    signal clicked(var name)
    property bool _hilighted2: false

    height: width * 2

    IconButton {
        id: icon1
        width: parent.width
        height: width
        z: 0
        icon.source: icon1Source

        onClicked: {
            _hilighted2 = false;
            iconSwitch.clicked(button1Name);
        }
    }

    IconButton {
        id: icon2
        width: parent.width
        height: width
        anchors.top: icon1.bottom
        z: 0
        icon.source: icon2Source

        onClicked: {
            _hilighted2 = true;
            iconSwitch.clicked(button2Name);
        }
    }

    Rectangle {
        id: highlighter
        radius: width / 2
        width: parent.width
        height: width
        opacity: 0.5
        z: 1
        y: _hilighted2 ? parent.height / 2 : 0
        Behavior on y { NumberAnimation {duration: 100 } }
    }
}

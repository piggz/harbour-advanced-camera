import QtQuick 2.2
import Sailfish.Silica 1.0

Item {
    id: button
    property string image: ""
    property alias icon: iconButton.icon
    property int size: Theme.itemSizeSmall
    signal clicked()

    height: size
    width: size

    Rectangle {
        anchors.fill: parent
        radius: width/2
        color: Theme.colorScheme === Theme.LightOnDark ? "black" : "white"
        opacity: 0.7
        
        IconButton {
            id: iconButton
            anchors.centerIn: parent
            icon.source: button.image
            onClicked: button.clicked()
        }
        Component.onCompleted:{
            console.log("btn", width, height);
        }
    }
}

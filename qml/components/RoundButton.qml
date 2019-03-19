import QtQuick 2.2
import Sailfish.Silica 1.0

Item {
    id: button
    property string image: ""
    property alias icon: iconButton.icon
    property int size: Theme.itemSizeSmall
    property alias down: iconButton.down
    signal clicked()
    signal pressed()

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
            anchors.fill: parent
            icon.anchors.fill: icon.parent
            icon.anchors.margins: Theme.paddingMedium
            icon.source: button.image
            icon.fillMode: Image.PreserveAspectFit
            onClicked: button.clicked()
            onPressed: button.pressed()
        }
    }
}

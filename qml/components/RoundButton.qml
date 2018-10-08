import QtQuick 2.2
import Sailfish.Silica 1.0

Item {
    id: button
    property string image: ""
    signal clicked()
    
    Rectangle {
        anchors.fill: parent
        radius: width/2
        color: "#222222"
        
        IconButton {
            anchors.centerIn: parent
            icon.source: button.image
            MouseArea {
                anchors.fill: parent

                onClicked: {
                    button.clicked()
                }
            }
        }
        Component.onCompleted:{
            console.log("btn", width, height);
        }
    }
}

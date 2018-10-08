import QtQuick 2.2
import Sailfish.Silica 1.0

Item {
    id: button
    property alias image: btnImage.source
    signal clicked()
    
    Rectangle {
        anchors.fill: parent
        radius: width/2   
        color: "red"
        
        Image {
            id: btnImage
            anchors.fill:parent    
        }
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


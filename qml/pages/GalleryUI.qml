import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: galleryPage

    property var photoList: ({})

    // The effective value will be restricted by ApplicationWindow.allowedOrientations
    allowedOrientations: Orientation.All

    SlideshowView {
        id: gallery

        clip: true
        width: parent.width
        height: parent.height

        model: photoList
        currentIndex: count - 1

        delegate: Rectangle {
            id: delegate
            width: parent.width
            height: parent.height
            color: 'black'

            Image {
                id: thumbnail

                asynchronous: true
                sourceSize.width: parent.width
                anchors.fill: parent
                fillMode: Image.PreserveAspectFit
                source: photoPath

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        console.log("Clicked", thumbnail.source)
                        Qt.openUrlExternally(thumbnail.source)
                    }
                }
            }
        }
    }
}

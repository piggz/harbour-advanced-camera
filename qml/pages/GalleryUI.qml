import QtQuick 2.0
import Sailfish.Silica 1.0
import uk.co.piggz.harbour_advanced_camera 1.0
import "../components/"

Page {
    id: galleryPage

    property var fileList: ({})

    // The effective value will be restricted by ApplicationWindow.allowedOrientations
    allowedOrientations: Orientation.All

    backNavigation: false

    function removeFile(idx) {
        var path = fileList.get(idx).filePath
        console.log("Removing", path)
        if (fsOperations.deleteFile( path )) {
            fileList.remove(idx)
            if (gallery.count === 0) {
                console.log("Closing empty gallery!")
                pageStack.pop()
            }
        } else {
            console.log("Error deleting file:", path);
        }
    }

    RoundButton {
        id: btnClose

        visible: true
        icon.source: "image://theme/icon-m-close"
        size: Theme.itemSizeMedium

        anchors {
            top: parent.top
            topMargin: Theme.paddingMedium
            right: parent.right
            rightMargin: Theme.paddingMedium
        }

        onClicked: {
            console.log("Clicked close button")
            pageStack.pop()
        }
    }

    RemorsePopup { id: remorse }

    Row {
        id: rowBottom

        visible: btnClose.visible
        anchors {
            horizontalCenter: parent.horizontalCenter
            bottom: parent.bottom
            bottomMargin: Theme.paddingMedium
        }

        RoundButton {
            id: btnRemove

            icon.source: "image://theme/icon-m-delete"
            size: Theme.itemSizeMedium

            function showRemorseItem() {
                remorse.execute(qsTr("Deleting"),
                    function() { removeFile(gallery.currentIndex) })
            }

            onClicked: {
                console.log("Clicked delete button")
                showRemorseItem()
            }
        }
    }

    SlideshowView {
        id: gallery

        clip: true
        width: parent.width
        height: parent.height
        z: -1

        model: fileList
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
                source: "file://" + filePath

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        console.log("Clicked", thumbnail.source)
                        btnClose.visible = btnClose.visible ? false : true
                    }
                }
            }
        }
    }

    FSOperations {
        id: fsOperations
    }
}

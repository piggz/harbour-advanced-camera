import QtQuick 2.5
import Sailfish.Silica 1.0
import QtMultimedia 5.6
import Nemo.Thumbnailer 1.0
import uk.co.piggz.harbour_advanced_camera 1.0
import "../components/"

Page {
    id: galleryPage

    property var fileList: ({

                            })
    property alias showButtons: btnClose.visible

    // The effective value will be restricted by ApplicationWindow.allowedOrientations
    allowedOrientations: Orientation.All

    backNavigation: false

    function removeFile(idx) {
        var path = fileList.get(idx).filePath
        console.log("Removing", path)
        if (fsOperations.deleteFile(path)) {
            fileList.remove(idx)
            if (gallery.count === 0) {
                console.log("Closing empty gallery!")
                pageStack.pop()
            }
        } else {
            console.log("Error deleting file:", path)
        }
    }

    function getFileName(idx) {
        var fullPath = fileList.get(idx).filePath
        var lastSep = fullPath.lastIndexOf("/")
        var fileName = fullPath.substr(lastSep + 1, fullPath.length - lastSep)
        return fileName
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

    RemorsePopup {
        id: remorse
    }

    Row {
        id: rowBottom

        visible: showButtons
        spacing: Theme.paddingMedium
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
                var deleteIndex = gallery.currentIndex
                remorse.execute(qsTr("Deleting %1").arg(getFileName(
                                                            deleteIndex)),
                                function () {
                                    removeFile(deleteIndex)
                                })
            }

            onClicked: {
                console.log("Clicked delete button")
                showRemorseItem()
            }
        }

        RoundButton {
            id: btnShare

            icon.source: "image://theme/icon-m-share"
            size: Theme.itemSizeMedium

            onClicked: {
                var filePath = fileList.get(gallery.currentIndex).filePath
                var mimeType = gallery.currentIndex.isVideo ? "video/mp4" : "image/jpeg"
                pageStack.push("Sailfish.TransferEngine.SharePage", {
                                   "source": filePath,
                                   "mimeType": mimeType
                               })
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

            Thumbnail {
                id: thumbnail

                sourceSize.width: parent.width
                sourceSize.height: parent.height
                anchors.fill: parent
                fillMode: Thumbnail.PreserveAspectFit
                source: filePath
                mimeType: isVideo ? "video/" : "image/"
                smooth: true

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        showButtons = !showButtons
                    }
                }
            }

            RoundButton {
                id: btnPlay

                visible: isVideo
                anchors.centerIn: parent
                icon.source: "image://theme/icon-m-play"
                size: Theme.itemSizeMedium

                onClicked: {
                    pageStack.push(Qt.resolvedUrl("VideoPlayer.qml"), {
                                       "videoFile": filePath
                                   }, PageStackAction.Immediate)
                }
            }
        }
    }
}

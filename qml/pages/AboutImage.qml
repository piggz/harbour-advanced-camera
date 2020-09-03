import QtQuick 2.0
import Sailfish.Silica 1.0
import QtMultimedia 5.6
import uk.co.piggz.harbour_advanced_camera 1.0
import "../components/"

Page {
    id: pageImage
    property var filePath
    property var fileName

    // The effective value will be restricted by ApplicationWindow.allowedOrientations
    allowedOrientations: Orientation.All

    function sizeToStr(siz) {
        return siz.width + "x" + siz.height
    }

    Image {
        id: image
        visible: false
        source: filePath
        asynchronous: true
        onStatusChanged: {
            if (status === Image.Ready) {
                mediaAbout.mediaSize = sizeToStr(sourceSize)
            }
        }
    }

    ExifModel {
        id: modelExif
        source: filePath
    }

    AboutMedia {
        id: mediaAbout
        mediaModel: modelExif
        mediaSize: ""
        file: fileName
        fileSize: fsOperations.getFileSizeHuman(filePath)
    }
}

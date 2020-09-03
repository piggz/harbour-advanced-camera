import QtQuick 2.0
import Sailfish.Silica 1.0
import QtMultimedia 5.6
import uk.co.piggz.harbour_advanced_camera 1.0
import "../components/"

Page {
    id: pageVideo
    property var filePath
    property var fileName

    // The effective value will be restricted by ApplicationWindow.allowedOrientations
    allowedOrientations: Orientation.All

    function sizeToStr(siz) {
        return siz.width + "x" + siz.height
    }

    function msToTime(millis) {
        return new Date(millis).toISOString().substr(11, 8)
    }

    MediaPlayer {
        id: mediaPlayer
        source: filePath
        autoPlay: false

        onStatusChanged: {
            if (status === MediaPlayer.Loaded) {
                mediaAbout.mediaSize = sizeToStr(metaData.resolution)
            }
        }

        onDurationChanged: {
            mediaAbout.mediaDuration = msToTime(duration)
        }

        Component.onCompleted: {
            modelVideo.setPlayer(mediaPlayer)
        }
    }

    MetadataModel {
        id: modelVideo
    }

    AboutMedia {
        id: mediaAbout
        mediaModel: modelVideo
        mediaSize: ""
        file: fileName
        fileSize: fsOperations.getFileSizeHuman(filePath)
        mediaDuration: ""
    }
}

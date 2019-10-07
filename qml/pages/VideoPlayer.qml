import QtQuick 2.0
import Sailfish.Silica 1.0
import QtMultimedia 5.6
import Nemo.KeepAlive 1.2
import uk.co.piggz.harbour_advanced_camera 1.0
import "../components/"

Page {
    id: videoPage

    property ListModel fileList

    // The effective value will be restricted by ApplicationWindow.allowedOrientations
    allowedOrientations: Orientation.All

    backNavigation: false

    property string videoFile
    property double controlsOpacity: 1.0

    DisplayBlanking {
        preventBlanking: player.playbackState === MediaPlayer.PlayingState
    }

    Rectangle {
        anchors.fill: parent
        color: "black"

        MediaPlayer {
            id: player

            source: "file://" + videoFile
            autoPlay: true

            onPositionChanged: {
                seekSlider.value = position
            }

            onStopped: {
                pageStack.pop(null, true)
            }
        }

        FrameGrabber {
            id: frameGrabber

            source: null
            baseDir: settings.global.storagePath

            onFrameGrabbed: {
                source = null
                console.log("Snapshot saved:", snapshotPath)
                fileList.append({
                                    "filePath": snapshotPath,
                                    "isVideo": false
                                })
            }
        }

        VideoOutput {
            id: video

            anchors.fill: parent
            source: player
            fillMode: VideoOutput.PreserveAspectFit

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    controlsOpacity > 0 ? controlsOpacity = 0 : controlsOpacity = 1.0
                }
            }
        }

        Rectangle {
            id: rectFlash
            anchors.fill: parent
            opacity: 0

            NumberAnimation on opacity {
                id: animFlash
                from: 1.0
                to: 0.0
                duration: 200
            }
        }

        Item {
            id: itemsControls
            anchors.fill: parent
            opacity: controlsOpacity

            Behavior on opacity {
                FadeAnimation {
                }
            }

            RoundButton {
                id: btnCloseVideo

                enabled: controlsOpacity > 0
                icon.source: "image://theme/icon-m-close"
                size: Theme.itemSizeMedium

                anchors {
                    top: parent.top
                    topMargin: Theme.paddingMedium
                    right: parent.right
                    rightMargin: Theme.paddingMedium
                }

                onClicked: {
                    pageStack.pop(null, true)
                }
            }

            RoundButton {
                id: btnPlayPause

                enabled: controlsOpacity > 0
                icon.source: player.playbackState === MediaPlayer.PlayingState ? "image://theme/icon-m-pause" : "image://theme/icon-m-play"
                size: Theme.itemSizeMedium
                anchors.centerIn: parent

                onClicked: {
                    if (player.playbackState === MediaPlayer.PausedState) {
                        player.play()
                    } else if (player.playbackState === MediaPlayer.PlayingState) {
                        player.pause()
                    } else if (player.playbackState === MediaPlayer.StoppedState) {
                        player.seek(0)
                        player.play()
                    }
                }
            }

            RoundButton {
                id: btnSnapshot

                enabled: controlsOpacity > 0
                icon.source: "image://theme/icon-m-camera"
                size: Theme.itemSizeMedium

                anchors {
                    verticalCenter: parent.verticalCenter
                    right: parent.right
                    rightMargin: Theme.paddingMedium
                }

                onClicked: {
                    animFlash.start()
                    frameGrabber.source = player
                }
            }

            Row {
                id: rowBottomVideo

                width: parent.width
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    bottom: parent.bottom
                    bottomMargin: Theme.paddingMedium
                }

                Slider {
                    id: seekSlider

                    width: parent.width
                    anchors.verticalCenter: parent.verticalCenter
                    minimumValue: 0
                    maximumValue: player.duration > 0 ? player.duration : 1
                    value: player.position
                    stepSize: 0
                    enabled: player.seekable && controlsOpacity > 0

                    onReleased: {
                        player.seek(value)
                    }
                }
            }

            Timer {
                running: true
                interval: 333
                repeat: false
                onTriggered: controlsOpacity = 0
            }
        }
    }
}

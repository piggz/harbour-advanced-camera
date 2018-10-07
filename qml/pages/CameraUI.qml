import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Media 1.0
//import com.jolla.camera 1.0
import QtMultimedia 5.4
import QtQuick.Layouts 1.0
import uk.co.piggz.harbour_advanced_camera 1.0
import "../components/"

Page {
    id: page

    // The effective value will be restricted by ApplicationWindow.allowedOrientations
    allowedOrientations: Orientation.Landscape

    Rectangle {
        parent: window
        anchors.fill: parent
        z: -1
        color: "black"
    }

    VideoOutput {
        id: captureView
        anchors.fill: parent
        source: camera
        rotation: 180
        orientation: camera.orientation
        onOrientationChanged: {
            console.log(orientation)
        }
    }

    Camera {
        id: camera

        imageProcessing.colorFilter: CameraImageProcessing.ColorFilterNormal

        viewfinder.resolution: Qt.size(1920, 1080)
        exposure {
            //exposureCompensation: -1.0
            exposureMode: Camera.ExposureAuto
        }

        flash.mode: Camera.FlashRedEyeReduction

        imageCapture {
            onImageCaptured: {
                photoPreview.source = preview  // Show the preview in an Image
            }
        }
    }

    Rectangle {
        id: btnCapture

        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: 50

        color: "red"

        height: parent.height / 6
        width: height
        radius: width/2

        border.color: "white"
        border.width: 20

        MouseArea {
            anchors.fill: parent
            onClicked: {
                camera.imageCapture.capture();
            }
        }
    }

    RowLayout {
        id: buttonLayout
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.left: parent.left
        anchors.margins: 20
        height: parent.height / 8
        spacing: 20
        Rectangle {
            color: '#999999'
            Layout.fillWidth: false
            Layout.minimumWidth: 300
            Layout.preferredWidth: 300
            Layout.maximumWidth: 300
            Layout.minimumHeight: 150
            Layout.preferredHeight: parent.height
            radius: 10
            Text {
                anchors.centerIn: parent
                text: "Effect"
            }
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    if (panelEffects.expanded) {
                        panelEffects.hide();
                    } else {
                        panelEffects.show();
                        panelExposure.hide();
                    }
                }
            }
        }

        Rectangle {
            color: '#999999'
            Layout.fillWidth: false
            Layout.minimumWidth: 300
            Layout.preferredWidth: 300
            Layout.maximumWidth: 300
            Layout.minimumHeight: 150
            Layout.preferredHeight: parent.height
            radius: 10
            Text {
                anchors.centerIn: parent
                text: "Exposure"
            }
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    if (panelExposure.expanded) {
                        panelExposure.hide();
                    } else {
                        panelExposure.show();
                        panelEffects.hide();
                    }
                }
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: parent.height
        }

    }

    DockedListView {
        id: panelEffects
        model: modelEffects

        onClicked: {
            camera.imageProcessing.setColorFilter(value);
        }
    }

    DockedListView {
        id: panelExposure
        model: modelExposure

        onClicked: {
            camera.exposure.setExposureMode(value);
        }
    }

    EffectsModel {
        id: modelEffects
    }

    ExposureModel {
        id: modelExposure
    }

    /*
    GStreamerVideoOutput {
        id: videoOutput
        source: camera
        orientation: camera.orientation

        onOrientationChanged: {
            console.log(orientation)
        }

        z: -1
        anchors.fill: parent

        Behavior on y {
            NumberAnimation { duration: 150; easing.type: Easing.InOutQuad }
        }
    }
    */

    Component.onCompleted: {
        modelEffects.setCamera(camera);
        modelExposure.setCamera(camera);
    }
}

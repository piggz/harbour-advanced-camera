import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Media 1.0
//import com.jolla.camera 1.0
import QtMultimedia 5.4
import QtQuick.Layouts 1.0
//import uk.co.piggz.harbour_advanced_camera 1.0
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

    Rectangle {
        id: buttonPanel
        property int buttonSize: ((height -Theme.paddingMedium) / 5) - Theme.paddingMedium
        property bool menuVisible: false
        color: "grey"
        height: parent.height
        width: buttonSize * 2 + 3 * Theme.paddingMedium
        x: menuVisible ? 0 : -(width / 2)
        y:0
        Behavior on x {
            NumberAnimation { duration: 150 }
        }
        
        
        Row {
            spacing: Theme.paddingMedium
            anchors.fill: parent
            ColumnLayout {
                id: colButtons
                spacing: Theme.paddingMedium
                width: buttonPanel.buttonSize
                
                RoundButton {
                    id: btnScene
                    Layout.preferredHeight: buttonPanel.buttonSize
                    Layout.preferredWidth: buttonPanel.buttonSize                    
                    Layout.fillHeight: false
                    
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
            Item {
                id: colMenu
                height: parent.height
                width: buttonPanel.buttonSize
                
                RoundButton {
                    id: btnMenu
                    height: buttonPanel.buttonSize
                    width: buttonPanel.buttonSize                    
                    anchors.verticalCenter: parent.verticalCenter
                    onClicked: {
                    	buttonPanel.menuVisible = !buttonPanel.menuVisible;
                    }
                }
                
	    
            }
            
        }

    }

    DockedListView {
        id: panelEffects
//        model: modelEffects

        onClicked: {
            camera.imageProcessing.setColorFilter(value);
        }
    }

    DockedListView {
        id: panelExposure
    //    model: modelExposure

        onClicked: {
            camera.exposure.setExposureMode(value);
        }
    }
/*
    EffectsModel {
        id: modelEffects
    }

    ExposureModel {
        id: modelExposure
    }
*/
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
      //  modelEffects.setCamera(camera);
      //  modelExposure.setCamera(camera);
    }
}

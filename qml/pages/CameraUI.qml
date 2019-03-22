import QtQuick 2.0
import Sailfish.Silica 1.0
import QtMultimedia 5.4
import uk.co.piggz.harbour_advanced_camera 1.0
import "../components/"

Page {
    id: page

    // The effective value will be restricted by ApplicationWindow.allowedOrientations
    allowedOrientations: Orientation.Landscape

    property string temp_resolution_str: ""
    property bool _cameraReload: false
    property bool _completed: false
    property bool _focusAndSnap: false
    property bool _parametersLoaded: false

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
        rotation: camera.position == Camera.FrontFace ? 0 : 180
        orientation: camera.orientation
        onOrientationChanged: {
            console.log(orientation);
        }
    }

    Camera {
        id: camera

        cameraState: page._completed && !page._cameraReload
                        ? Camera.ActiveState
                        : Camera.UnloadedState

        imageProcessing.colorFilter: CameraImageProcessing.ColorFilterNone

        viewfinder.resolution: Qt.size(1920, 1080)
        exposure {
            //exposureCompensation: -1.0
            exposureMode: Camera.ExposureAuto
        }

        flash.mode: Camera.FlashOff

        imageCapture {
            onImageCaptured: {
                photoPreview.source = preview  // Show the preview in an Image
                console.log("Camera: captured", photoPreview.source);
            }
            onImageSaved: {
                console.log("Camera: image saved", path)
                galleryModel.append({ filePath: path });
            }
        }
        onLockStatusChanged: {
            if (camera.lockStatus == Camera.Locked && _focusAndSnap) {
                camera.imageCapture.capture();
                animFlash.start();
                _focusAndSnap = false;
            }
        }

        onCameraStatusChanged: {
            console.log("Camera status:", cameraStatus);

            if (cameraStatus == Camera.ActiveStatus && !_parametersLoaded) {
                settingsOverlay.setCamera(camera);
                _parametersLoaded = true;
                applySettings();
            }
        }
    }

    Image {
        id: photoPreview

        onStatusChanged: {
            if (photoPreview.status == Image.Ready) {
                console.log('photoPreview ready');
            }
        }
    }

    RoundButton {
        id: btnCapture

        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: Theme.paddingMedium

        size: Theme.itemSizeLarge

        image: "image://theme/icon-camera-shutter"
        icon.anchors.margins: Theme.paddingSmall
        onClicked: {
            if (camera.focus.focusMode == Camera.FocusAuto || camera.focus.focusMode == Camera.FocusMacro || camera.focus.focusMode == Camera.FocusContinuous) {
                _focusAndSnap = true;
                camera.searchAndLock();
            } else {
                camera.imageCapture.capture();
                animFlash.start();
            }
        }
    }

    Rectangle {
        id: rectFlash
        anchors.fill: parent
        opacity: 0

        NumberAnimation on opacity {id:animFlash; from: 1.0; to: 0.0; duration: 200 }
    }

    Rectangle {
        id: focusCircle
        height: Theme.itemSizeHuge
        width: height
        radius: width / 2
        border.width: 2
        border.color: focusColor()
        color: "transparent"
        x: parent.width / 2
        y: parent.height / 2
        transform: Translate {
            x: -focusCircle.width / 2
            y: -focusCircle.height / 2
        }

    }

    Label {
        id: lblResolution
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.margins: Theme.paddingMedium
        color: Theme.lightPrimaryColor
        text: temp_resolution_str
    }

    MouseArea {
        id: mouseFocusArea
        anchors.fill: parent
        z: -1 //Send to back
        onClicked: {
            // If in auto or macro focus mode, focus on the specified point
            if (camera.focus.focusMode == Camera.FocusAuto || camera.focus.focusMode == Camera.FocusMacro || camera.focus.focusMode == Camera.FocusContinuous) {
                focusCircle.x = mouse.x;
                focusCircle.y = mouse.y;

                camera.focus.focusPointMode = Camera.FocusPointCustom;
                camera.focus.setCustomFocusPoint(Qt.point((mouse.x / page.width), (mouse.y / page.height)));
            }
            camera.searchAndLock();
        }
    }

    ListModel {
        id: galleryModel
    }

    ListModel {
        id: viewfinderResolutionModel
    }

    SettingsOverlay {
        id: settingsOverlay
    }

    Component.onCompleted: {
        _completed = true;
    }

    Timer {
        id: reloadTimer
        interval: 100
        running: page._cameraReload && camera.cameraStatus == Camera.UnloadedStatus
        onTriggered: {
            page._cameraReload = false;
        }
     }

    function applySettings() {
        camera.imageProcessing.setColorFilter(settings.mode.effect);
        camera.exposure.setExposureMode(settings.mode.exposure);
        camera.flash.setFlashMode(settings.mode.flash);
        camera.imageProcessing.setWhiteBalanceMode(settings.mode.whiteBalance);
        setFocusMode(settings.mode.focus);

        if (settings.mode.iso === 0) {
            camera.exposure.setAutoIsoSensitivity();
        } else {
            camera.exposure.setManualIsoSensitivity(settings.mode.iso);
        }

        camera.imageCapture.setResolution(settings.strToSize(settings.mode.resolution));
        temp_resolution_str = settings.mode.resolution;
        settings.global.cameraCount = QtMultimedia.availableCameras.length;
    }

    function setFocusMode(focus) {
        if (camera.focus.focusMode !== focus) {
            camera.unlock();
            camera.focus.setFocusMode(focus);
            settings.mode.focus = focus;

            //Set the focus point pack to centre
            focusCircle.x = page.width / 2;
            focusCircle.y = page.height / 2;

            camera.focus.focusPointMode = Camera.FocusPointAuto;
            camera.searchAndLock();
        }
    }

    RoundButton {
        id: btnGallery

        visible: galleryModel.count > 0
        enabled: visible

        anchors.bottom: parent.bottom
        anchors.bottomMargin: Theme.paddingMedium
        anchors.right: parent.right
        anchors.rightMargin: Theme.paddingMedium

        size: Theme.itemSizeSmall

        image: "image://theme/icon-m-image"

        onClicked: {
            pageStack.push(Qt.resolvedUrl("GalleryUI.qml"), { "fileList": galleryModel });
        }
    }

    IconButton {
        id: btnCameraSwitch
        icon.source: "image://theme/icon-camera-switch"
        visible: settings.global.cameraCount > 1
        anchors {
            top: parent.top
            topMargin: Theme.paddingMedium
            right: parent.right
            rightMargin: Theme.paddingMedium
        }
        onClicked: {
            _cameraReload = true
            camera.stop();
            camera.deviceId = settings.global.cameraId == "primary" ? "secondary" : "primary";
            camera.start();
            settings.global.cameraId = camera.deviceId;
        }
    }

    function focusColor() {
        if (camera.lockStatus == Camera.Unlocked) {
            return Theme.highlightColor;
        } else if (camera.lockStatus == Camera.Searching) {
            return Theme.secondaryColor;
        } else {
            return Theme.primaryColor;
        }
    }
}

import QtQuick 2.0
import Sailfish.Silica 1.0
import QtMultimedia 5.6
import QtSensors 5.0
import uk.co.piggz.harbour_advanced_camera 1.0
import "../components/"

Page {
    id: page

    // The effective value will be restricted by ApplicationWindow.allowedOrientations
    allowedOrientations: Orientation.Landscape

    property bool _cameraReload: false
    property bool _completed: false
    property bool _focusAndSnap: false
    property bool _parametersLoaded: false
    property bool _recordingVideo: false
    readonly property int zoomStepSize: 5
    property int controlsRotation: 0

    // Use Orientation Sensor to sense orientation change
    OrientationSensor { id: orientationSensor; active: true }

    // Orientation sensors for primary (back camera) & secondary (front camera)
    readonly property var _rotationValues: {
        "primary": [270, 270, 90, 180 ,0],
        "secondary": [90, 90, 270, 180, 0]
    }

    NumberAnimation on controlsRotation { running: camera._orientation === 1; to: -90;   duration: 200 }
    NumberAnimation on controlsRotation { running: camera._orientation === 2; to: 90; duration: 200 }
    NumberAnimation on controlsRotation { running: camera._orientation === 3; to: 180; duration: 200 }
    NumberAnimation on controlsRotation { running: camera._orientation === 4; to: 0;  duration: 200 }

    focus: true

    Rectangle {
        parent: window
        anchors.fill: parent
        z: -1
        color: "black"
    }

    FSOperations {
        id: fsOperations
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

    GridOverlay {
        aspect: settings.global.captureMode == "image" ? ratio(camera.imageCapture.resolution) : ratio(camera.videoRecorder.resolution)

        function ratio(resolution) {
            return resolution.width / resolution.height
        }
    }

    Slider {
        id: zoomSlider
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        width: parent.width * 0.75
        minimumValue: 1
        maximumValue: camera.maximumDigitalZoom
        value: camera.digitalZoom
        stepSize: zoomStepSize
        rotation: {
            // Zoom slider should be slide up to zoom in
            if (camera._orientation  === 1 ) return -180
            else if (camera._orientation === 2) return 0
            else return controlsRotation }

        onValueChanged: {
            if (value != camera.digitalZoom) camera.digitalZoom = value;
        }

        Connections {
            target: camera

            onDigitalZoomChanged: {
                zoomSlider.value = camera.digitalZoom;
            }
        }
    }


    Camera {
        id: camera

        cameraState: page._completed && !page._cameraReload
                     ? Camera.ActiveState
                     : Camera.UnloadedState

        imageProcessing.colorFilter: CameraImageProcessing.ColorFilterNone

        // Use easy device orientation values
        // 0=unknown, 1=portrait, 2=portrait inverted, 3=landscape, 4=landscape inverted
        readonly property int _orientation: orientationSensor.reading ?
                                               orientationSensor.reading.orientation :
                                               0

        // Write Orientation to metadata
        metaData.orientation: _rotationValues[deviceId][_orientation]

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
            onResolutionChanged: {
                console.log("Image resolution changed:", settings.resolution("image"));
                camera.viewfinder.resolution = getNearestViewFinderResolution();
            }
        }

        videoRecorder {
            audioSampleRate: 48000
            audioBitRate: 96
            audioChannels: 1
            audioCodec: "audio/mpeg, mpegversion=(int)4"
            frameRate: 30
            videoCodec: "video/x-h264"
            mediaContainer: "video/quicktime, variant=(string)iso"
            videoEncodingMode: CameraRecorder.AverageBitRateEncoding
            videoBitRate: 12000000

            onRecorderStateChanged: {
                if (camera.videoRecorder.recorderState == CameraRecorder.StoppedState) {
                    console.log("saved to: " + camera.videoRecorder.outputLocation)
                }
            }

            onResolutionChanged: {
                console.log("Video resolution changed:", settings.resolution("video"));
                camera.viewfinder.resolution = getNearestViewFinderResolution();
            }
        }

        onLockStatusChanged: {
            if (camera.lockStatus == Camera.Locked && _focusAndSnap && !_recordingVideo) {
                camera.imageCapture.captureToLocation(fsOperations.writableLocation("image") + "/AdvancedCam/IMG_" + Qt.formatDateTime(new Date(), "yyyyMMdd_hhmmss") + ".jpg");
                animFlash.start();
                _focusAndSnap = false;
            }
        }

        onCameraStatusChanged: {
            console.log("Camera status:", cameraStatus);

            if (cameraStatus == Camera.ActiveStatus && !_parametersLoaded) {
                if (zoomSlider.maximumValue != camera.maximumDigitalZoom) {
                    zoomSlider.maximumValue = camera.maximumDigitalZoom;
                }

                settingsOverlay.setCamera(camera);
                if (settings.global.captureMode === "video") {
                    camera.captureMode = Camera.CaptureVideo;
                    btnModeSwitch._hilighted2 = true;
                } else {
                    camera.captureMode = Camera.CaptureStillImage;
                    btnModeSwitch._hilighted2 = false;
                }

                settingsOverlay.setMode(settings.global.captureMode);

                camera.viewfinder.resolution = getNearestViewFinderResolution();
                _parametersLoaded = true;
                applySettings();
                lblResolution.forceUpdate = !lblResolution.forceUpdate
            }
        }
    }

    Image {
        id: photoPreview
        rotation: page.controlsRotation
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
        rotation: page.controlsRotation

        image: shutterIcon()
        icon.anchors.margins: Theme.paddingSmall
        onClicked: {
            if (camera.captureMode == Camera.CaptureStillImage) {
                if (camera.focus.focusMode == Camera.FocusAuto || camera.focus.focusMode == Camera.FocusMacro || camera.focus.focusMode == Camera.FocusContinuous) {
                    _focusAndSnap = true;
                    camera.searchAndLock();
                } else {
                    camera.imageCapture.captureToLocation(fsOperations.writableLocation("image") + "/AdvancedCam/IMG_" + Qt.formatDateTime(new Date(), "yyyyMMdd_hhmmss") + ".jpg")
                    animFlash.start();
                }
            } else {
                if (camera.videoRecorder.recorderStatus == CameraRecorder.RecordingStatus) {
                    camera.videoRecorder.stop();
                } else {
                    camera.videoRecorder.outputLocation = fsOperations.writableLocation("video") + "/AdvancedCam/VID_" + Qt.formatDateTime(new Date(), "yyyyMMdd_hhmmss") + ".mp4";
                    camera.videoRecorder.record();
                }
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

    Row {
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: Theme.paddingMedium
        rotation: page.controlsRotation
        transformOrigin: {
            if (camera._orientation == 1) return Item.Right
            else if (camera._orientation == 2) return Item.Left
            else return Item.Center
        }

        Label {
            property bool forceUpdate: false
            id: lblResolution
            color: Theme.lightPrimaryColor
            text: (forceUpdate || !forceUpdate) ? settings.sizeToStr(settings.resolution(settings.global.captureMode)) : ""
        }

        Label {
            id: lblRecordTime
            visible: settings.global.captureMode == "video"
            color: Theme.lightPrimaryColor
            //text: Qt.formatDateTime(new Date(camera.videoRecorder.duration), "hh:mm:ss") //Doest work as return 01:00:00 for 0
            text: msToTime(camera.videoRecorder.duration)
        }
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
        iconRotation: page.controlsRotation
    }

    Component.onCompleted: {
        camera.deviceId = settings.global.cameraId;
        _completed = true;
        fsOperations.createFolder(fsOperations.writableLocation("image") + "/AdvancedCam/");
        fsOperations.createFolder(fsOperations.writableLocation("video") + "/AdvancedCam/");
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
        console.log("Applying settings in mode ", settings.global.captureMode);
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

        camera.imageCapture.setResolution(settings.resolution("image"));
        camera.videoRecorder.resolution = settings.resolution("video");

        settings.global.cameraCount = QtMultimedia.availableCameras.length;
    }

    function setFocusMode(focus) {
        if (camera.focus.focusMode !== focus) {
            camera.stop();
            camera.focus.setFocusMode(focus);
            camera.start();
            settings.mode.focus = focus;

            //Set the focus point pack to centre
            focusCircle.x = page.width / 2;
            focusCircle.y = page.height / 2;

            camera.focus.focusPointMode = Camera.FocusPointAuto;
            camera.searchAndLock();
        }
    }

    function getNearestViewFinderResolution() {
        /// Tries to find the most correct ViewFinder resolution
        /// for the selected camera settings
        ///
        /// In order of preference:
        ///  * viewFinderResolution for the nearest aspect ratio as set in jolla-camera's dconf settings
        ///  * viewFinderResolution as set in jolla-camera's dconf settings
        ///  * First resolution as returned by camera.supportedViewfinderResolutions()
        ///  * device resolution

        var currentRatioSize = modelResolution.sizeToRatio(settings.resolution(settings.global.captureMode));
        var currentRatio = currentRatioSize.height > 0 ? currentRatioSize.width / currentRatioSize.height : 0;
        if (currentRatio > 0) {
            if (currentRatio <= 4.0 / 3 && settings.jollaCamera.viewfinderResolution_4_3) {
                return settings.strToSize(settings.jollaCamera.viewfinderResolution_4_3);
            } else if (settings.jollaCamera.viewfinderResolution_16_9) {
                return settings.strToSize(settings.jollaCamera.viewfinderResolution_16_9);
            }
        }

        if (settings.jollaCamera.viewfinderResolution) {
            return settings.strToSize(settings.jollaCamera.viewfinderResolution);
        }

        var supportedResolutions = camera.supportedViewfinderResolutions();
        if (supportedResolutions.length > 0) {
            //TODO find the best resolution for the correct aspect ratio
            //when we fix supportedViewfinderResolutions()
            return supportedResolutions[0];
        }

        return Qt.size(Screen.height, Screen.width);

    }

    RoundButton {
        id: btnGallery

        visible: galleryModel.count > 0
        enabled: visible

        anchors.top: btnCameraSwitch.bottom
        anchors.bottomMargin: Theme.paddingMedium
        anchors.right: parent.right
        anchors.rightMargin: Theme.paddingMedium
        icon.rotation: page.controlsRotation

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
        icon.rotation: page.controlsRotation
        anchors {
            top: parent.top
            topMargin: Theme.paddingMedium
            right: parent.right
            rightMargin: Theme.paddingMedium
        }
        onClicked: {
            _cameraReload = true;
            camera.stop();
            camera.deviceId = settings.global.cameraId == "primary" ? "secondary" : "primary";
            camera.start();
            settings.global.cameraId = camera.deviceId;
            if (settings.mode.resolution) {
                camera.imageCapture.setResolution(settings.strToSize(settings.mode.resolution));
            }
        }
    }

    IconSwitch {
        id: btnModeSwitch
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Theme.paddingMedium
        anchors.right: parent.right
        anchors.rightMargin: Theme.paddingMedium
        rotation: page.controlsRotation
        width: Theme.itemSizeSmall

        icon1Source: "image://theme/icon-camera-camera-mode"
        icon2Source: "image://theme/icon-camera-video"
        button1Name: "image"
        button2Name: "video"

        onClicked: {
            console.log("selected:", name);
            camera.stop();
            settingsOverlay.setMode(name, camera);
            if (name === button1Name) {
                camera.captureMode = Camera.CaptureStillImage;
            } else {
                camera.captureMode = Camera.CaptureVideo;
            }
            applySettings();
            camera.start();
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

    function shutterIcon() {
        if (camera.captureMode == Camera.CaptureStillImage) {
            return "image://theme/icon-camera-shutter"
        } else {
            if (camera.videoRecorder.recorderStatus == CameraRecorder.RecordingStatus) {
                return "image://theme/icon-camera-video-shutter-off";
            } else {
                return "image://theme/icon-camera-video-shutter-on";
            }
        }
    }
    function msToTime(millis) {
        return new Date(millis).toISOString().substr(11, 8);
    }

    Connections {
        target: window

        onActiveFocusChanged: {
            if (!window.activeFocus) {
                camera.stop();
            } else {
                camera.start();
            }
        }
    }

    Keys.onVolumeUpPressed: {
        if (settings.global.swapZoomControl) {
            zoomOut();
        } else {
            zoomIn();
        }
    }

    Keys.onVolumeDownPressed: {
        if (settings.global.swapZoomControl) {
            zoomIn();
        } else {
            zoomOut();
        }
    }

    function zoomIn() {
        if (camera.digitalZoom < camera.maximumDigitalZoom) {
            camera.digitalZoom += zoomStepSize;
        }
    }

    function zoomOut() {
        if (camera.digitalZoom > 1) {
            camera.digitalZoom -= zoomStepSize;
        }
    }
}

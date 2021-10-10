import QtQuick 2.0
import QtQuick.Layouts 1.0
import QtMultimedia 5.4
import Sailfish.Silica 1.0
import uk.co.piggz.harbour_advanced_camera 1.0
import "../components/"

Item {
    anchors.fill: parent
    property int iconRotation: 0
    property bool panelOpen: panelEffects.expanded || panelExposure.expanded
                             || panelFlash.expanded
                             || panelWhiteBalance.expanded
                             || panelFocus.expanded || panelIso.expanded
                             || panelResolution.expanded
                             || panelStorage.expanded || panelGeneral.expanded

    Item {
        id: buttonPanel
        opacity: (panelOpen ? 0 : 1)
        enabled: !panelOpen

        height: parent.height
        width: 2 * Theme.itemSizeSmall + 4 * Theme.paddingMedium
        anchors.left: parent.left
        anchors.top: parent.top

        Behavior on opacity {
            FadeAnimation {
            }
        }

        GridLayout {
            id: colButtons
            flow: GridLayout.TopToBottom
            rowSpacing: Theme.paddingSmall
            columnSpacing: Theme.paddingSmall
            rows: Math.floor(
                      height / (btnScene.height + rowSpacing)) //using the button height and not theme size incase we change the RoundButton size

            anchors {
                top: parent.top
                bottom: parent.bottom
                left: parent.left
                margins: Theme.paddingSmall
            }

            RoundButton {
                id: btnScene
                icon.color: Theme.primaryColor
                icon.rotation: iconRotation
                image: effectIcon()
                visible: modelEffects.rowCount > 1

                onClicked: {
                    panelEffects.show()
                }
            }
            RoundButton {
                id: btnExposure
                image: sceneModeIcon()
                icon.color: Theme.primaryColor
                icon.rotation: iconRotation
                visible: modelExposure.rowCount > 1

                onClicked: {
                    panelExposure.show()
                }
            }
            RoundButton {
                id: btnFocus
                image: focusIcon()
                icon.rotation: iconRotation
                visible: modelFocus.rowCount > 1

                onClicked: {
                    panelFocus.show()
                }
            }
            RoundButton {
                id: btnResolution
                icon.color: Theme.primaryColor
                icon.rotation: iconRotation
                image: "../pics/icon-m-resolution.png"
                visible: modelResolution.rowCount > 1

                onClicked: {
                    panelResolution.show()
                }
            }
            RoundButton {
                id: btnWhiteBalance
                image: whiteBalanceIcon()
                icon.rotation: iconRotation
                visible: modelWhiteBalance.rowCount > 1

                onClicked: {
                    panelWhiteBalance.show()
                }
            }
            RoundButton {
                id: btnFlash
                image: flashIcon()
                icon.rotation: iconRotation
                visible: modelFlash.rowCount > 1

                onClicked: {
                    panelFlash.show()
                }
            }

            RoundButton {
                id: btnIso
                icon.color: Theme.primaryColor
                icon.rotation: iconRotation
                image: isoIcon()
                visible: modelIso.rowCount > 1

                onClicked: {
                    panelIso.show()
                }
            }

            RoundButton {
                id: btnStorage
                objectName: "btnStorage"
                icon.color: Theme.primaryColor
                icon.rotation: iconRotation
                image: "image://theme/icon-m-sd-card"
                visible: modelStorage.rowCount > 1

                onClicked: {
                    modelStorage.scan("/media/sdcard")
                    panelStorage.show()
                }
            }

            RoundButton {
                id: btnGeneral
                icon.color: Theme.primaryColor
                icon.rotation: iconRotation
                image: "image://theme/icon-m-developer-mode"

                onClicked: {
                    panelGeneral.show()
                }
            }
        }
    }

    DockedListView {
        id: panelEffects
        model: modelEffects
        selectedItem: settings.mode.effect
        rotation: iconRotation
        width: (iconRotation === 90
                || iconRotation === 270) ? parent.height : parent.width / 2

        onClicked: {
            camera.imageProcessing.setColorFilter(value)
            settings.mode.effect = value
            hide()
        }
    }

    DockedListView {
        id: panelExposure
        model: modelExposure
        selectedItem: settings.mode.exposure
        rotation: iconRotation
        width: (iconRotation === 90
                || iconRotation === 270) ? parent.height : parent.width / 2

        onClicked: {
            camera.exposure.setExposureMode(value)
            settings.mode.exposure = value
            hide()
        }
    }

    DockedListView {
        id: panelFlash
        model: modelFlash
        selectedItem: settings.mode.flash
        rotation: iconRotation
        width: (iconRotation === 90
                || iconRotation === 270) ? parent.height : parent.width / 2

        onClicked: {
            camera.flash.setFlashMode(value)
            settings.mode.flash = value
            hide()
        }
    }

    DockedListView {
        id: panelWhiteBalance
        model: modelWhiteBalance
        selectedItem: settings.mode.whiteBalance
        rotation: iconRotation
        width: (iconRotation === 90
                || iconRotation === 270) ? parent.height : parent.width / 2

        onClicked: {
            camera.imageProcessing.setWhiteBalanceMode(value)
            settings.mode.whiteBalance = value
            hide()
        }
    }

    DockedListView {
        id: panelFocus
        model: modelFocus
        selectedItem: settings.mode.focus
        rotation: iconRotation
        width: (iconRotation === 90
                || iconRotation === 270) ? parent.height : parent.width / 2

        onClicked: {
            setFocusMode(value)
            hide()
        }
    }

    DockedListView {
        id: panelIso
        model: modelIso
        selectedItem: settings.mode.iso
        rotation: iconRotation
        width: (iconRotation === 90
                || iconRotation === 270) ? parent.height : parent.width / 2

        onClicked: {
            if (value === 0) {
                camera.exposure.setAutoIsoSensitivity()
            } else {
                camera.exposure.setManualIsoSensitivity(value)
            }
            settings.mode.iso = value
            hide()
        }
    }

    DockedListView {
        id: panelResolution
        model: sortedModelResolution
        selectedItem: settings.resolution(settings.global.captureMode)
        rotation: iconRotation
        width: (iconRotation === 90
                || iconRotation === 270) ? parent.height : parent.width / 2

        onClicked: {
            settings.mode.resolution = settings.sizeToStr(value)
            hide()
            console.log("selected resolution", value, settings.mode.resolution)
            if (settings.global.captureMode === "video") {
                camera.videoRecorder.resolution = value
            } else {
                camera.imageCapture.setResolution(value)
            }
        }
    }

    DockedListView {
        id: panelStorage
        model: modelStorage
        selectedItem: settings.global.storagePath
        rotation: iconRotation
        width: (iconRotation === 90
                || iconRotation === 270) ? parent.height : parent.width / 2

        onClicked: {
            settings.global.storagePath = value
            hide()
        }

        Component.onCompleted: {
            restoreStorage()
        }
    }

    DockedPanel {
        id: panelGeneral
        modal: true
        animationDuration: 250
        width: (iconRotation === 90
                || iconRotation === 270) ? parent.height : parent.width / 2
        height: parent.height
        z: 99
        dock: Dock.Left
        clip: true
        rotation: iconRotation

        onVisibleChanged: {
            if (loadingComplete) {
                if (visible) {
                    console.log("loading...")
                    sldAudioBitrate.value = settings.global.audioBitrate;
                    sldVideoBitrate.value = settings.global.videoBitrate;
                } else {
                    console.log("saving...")
                    settings.global.audioBitrate = sldAudioBitrate.value;
                    settings.global.videoBitrate = sldVideoBitrate.value;
                }
            }
        }

        Rectangle {
            anchors.fill: parent
            color: Theme.colorScheme === Theme.LightOnDark ? "black" : "white"
            opacity: 0.7

            SilicaFlickable {
                anchors.fill: parent
                anchors.margins: Theme.paddingMedium
                contentHeight: mainColumn.height
                VerticalScrollDecorator {
                }
                Column {
                    id: mainColumn
                    width: parent.width
                    height: childrenRect.height
                    spacing: Theme.paddingMedium
                    TextSwitch {
                        id: zoomSwitch
                        text: qsTr("Swap zoom controls")
                        checked: settings.global.swapZoomControl
                        onCheckedChanged: {
                            settings.global.swapZoomControl = checked
                        }
                    }

                    ComboBox {
                        id: gridSwitch

                        property var grids: [{
                                "id": "none",
                                "name": qsTr("None")
                            }, {
                                "id": "thirds",
                                "name": qsTr("Thirds")
                            }, {
                                "id": "ambience",
                                "name": qsTr("Ambience")
                            }]

                        function findIndex(id) {
                            for (var i = 0; i < grids.length; i++) {
                                if (grids[i]["id"] === id) {
                                    return i
                                }
                            }
                            return 0
                        }

                        label: qsTr("Grid:")
                        currentIndex: findIndex(settings.global.gridMode)

                        menu: ContextMenu {
                            Repeater {
                                model: gridSwitch.grids

                                delegate: MenuItem {
                                    text: modelData["name"]

                                    onClicked: {
                                        settings.global.gridMode = modelData["id"]
                                    }
                                }
                            }
                        }
                    }
                    Slider {
                        id: sldVideoBitrate
                        label: qsTr("Video Bitrate")
                        width: parent.width
                        minimumValue: 6400000
                        maximumValue: 32000000
                        stepSize: 800000
                        Text {
                            text: sldVideoBitrate.value
                            anchors.centerIn: parent
                        }

                    }
                    Slider {
                        id: sldAudioBitrate
                        label: qsTr("Audio Bitrate")
                        width: parent.width
                        minimumValue: 64000
                        maximumValue: 320000
                        stepSize: 8-000
                        Text {
                            text: sldAudioBitrate.value
                            anchors.centerIn: parent
                        }

                    }
                    TextSwitch{
                        id: locationMetadataSwitch
                        width: parent.width

                        checked: settings.global.locationMetadata
                        text: qsTr("Store GPS location to metadata")

                        onCheckedChanged: {
                            settings.global.locationMetadata = checked;
                        }
                    }


                    TextSwitch{
                        id: wideSelectionSwitch
                        width: parent.width

                        checked: settings.global.enableWideCameraButtons
                        text: qsTr("Enable wide camera selection")

                        onCheckedChanged: {
                            settings.global.enableWideCameraButtons = checked;
                        }
                    }

                    Label {
                        text: qsTr("Disabled Cameras")
                    }

                    Row {
                        width: parent.width
                        spacing: 5
                        Repeater {
                            model: QtMultimedia.availableCameras
                            Rectangle {
                                width: Theme.itemSizeSmall
                                height: width
                                color: (settings.global.disabledCameras.indexOf("[" + QtMultimedia.availableCameras[index].deviceId + "]") >=0) ? "red" : "green"
                                Label  {
                                    anchors.centerIn: parent
                                    text: QtMultimedia.availableCameras[index].deviceId
                                }
                                MouseArea {
                                    anchors.fill: parent

                                    onClicked: {
                                        console.log("Clicked ", QtMultimedia.availableCameras[index].deviceId)
                                        if (settings.global.disabledCameras.indexOf("[" + QtMultimedia.availableCameras[index].deviceId + "]") >=0) {
                                            settings.global.disabledCameras = settings.global.disabledCameras.replace("[" + QtMultimedia.availableCameras[index].deviceId + "]", "")
                                        } else {
                                            settings.global.disabledCameras += ("[" + QtMultimedia.availableCameras[index].deviceId + "]")
                                        }

                                        console.log(settings.global.disabledCameras)
                                        settings.calculateEnabledCameras()
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    EffectsModel {
        id: modelEffects
    }

    ExposureModel {
        id: modelExposure
    }

    IsoModel {
        id: modelIso
    }

    WhiteBalanceModel {
        id: modelWhiteBalance
    }

    FocusModel {
        id: modelFocus
    }

    FlashModel {
        id: modelFlash
    }

    function setCamera(cam) {
        modelExposure.setCamera(cam)
        modelEffects.setCamera(cam)
        modelIso.setCamera(cam)
        modelWhiteBalance.setCamera(cam)
        modelFocus.setCamera(cam)
        modelFlash.setCamera(cam)
        modelResolution.setImageCapture(cam.imageCapture)
        modelResolution.setVideoRecorder(cam.videoRecorder)
        modelResolution.setMode(settings.global.captureMode)
    }

    function flashIcon() {
        var flashIcon = ""
        switch (settings.mode.flash) {
        case Camera.FlashAuto:
            flashIcon = "image://theme/icon-camera-flash-automatic"
            break
        case Camera.FlashOn:
            flashIcon = "image://theme/icon-camera-flash-on"
            break
        case Camera.FlashOff:
            flashIcon = "image://theme/icon-camera-flash-off"
            break
        case Camera.FlashRedEyeReduction:
            flashIcon = "image://theme/icon-camera-flash-redeye"
            break
        default:
            flashIcon = "image://theme/icon-camera-flash-on"
            break
        }
        return flashIcon
    }

    function focusIcon() {
        var focusIcon = ""
        switch (settings.mode.focus) {
        case Camera.FocusAuto:
            focusIcon = "image://theme/icon-camera-focus-auto"
            break
        case Camera.FocusManual:
            focusIcon = "../pics/icon-camera-focus-manual.png"
            break
        case Camera.FocusMacro:
            focusIcon = "image://theme/icon-camera-focus-macro"
            break
        case Camera.FocusHyperfocal:
            focusIcon = "../pics/icon-camera-focus-hyperfocal.png"
            break
        case Camera.FocusContinuous:
            focusIcon = "../pics/icon-camera-focus-continuous.png"
            break
        case Camera.FocusInfinity:
            focusIcon = "image://theme/icon-camera-focus-infinity"
            break
        default:
            focusIcon = "image://theme/icon-camera-focus"
            break
        }
        return focusIcon
    }

    function whiteBalanceIcon() {
        var wbIcon = ""
        switch (settings.mode.whiteBalance) {
        case CameraImageProcessing.WhiteBalanceAuto:
            wbIcon = "image://theme/icon-camera-wb-automatic"
            break
        case CameraImageProcessing.WhiteBalanceSunlight:
            wbIcon = "image://theme/icon-camera-wb-sunny"
            break
        case CameraImageProcessing.WhiteBalanceCloudy:
            wbIcon = "image://theme/icon-camera-wb-cloudy"
            break
        case CameraImageProcessing.WhiteBalanceShade:
            wbIcon = "image://theme/icon-camera-wb-shade"
            break
        case CameraImageProcessing.WhiteBalanceTungsten:
            wbIcon = "image://theme/icon-camera-wb-tungsten"
            break
        case CameraImageProcessing.WhiteBalanceFluorescent:
            wbIcon = "image://theme/icon-camera-wb-fluorecent"
            break
        case CameraImageProcessing.WhiteBalanceSunset:
            wbIcon = "image://theme/icon-camera-wb-sunset"
            break
        case CameraImageProcessing.WhiteBalanceFlash:
            wbIcon = "image://theme/icon-camera-wb-default" //TODO need icon
            break
        default:
            wbIcon = "image://theme/icon-camera-wb-default"
            break
        }
        return wbIcon
    }

    function isoIcon() {
        var iso = ""
        if (settings.mode.iso === 0) {
            iso = "../pics/icon-m-iso-auto.png"
        } else if (settings.mode.iso === 1) {
            iso = "../pics/icon-m-iso-hjr.png"
        } else {
            iso = "../pics/icon-m-iso-" + settings.mode.iso + ".png"
        }
        return iso
    }

    function effectIcon() {
        var effectIcon = ""

        switch (settings.mode.effect) {
        case CameraImageProcessing.ColorFilterNone:
            effectIcon = "none"
            break
        case CameraImageProcessing.ColorFilterAqua:
            effectIcon = "aqua"
            break
        case CameraImageProcessing.ColorFilterBlackboard:
            effectIcon = "blackboard"
            break
        case CameraImageProcessing.ColorFilterGrayscale:
            effectIcon = "grayscale"
            break
        case CameraImageProcessing.ColorFilterNegative:
            effectIcon = "negative"
            break
        case CameraImageProcessing.ColorFilterPosterize:
            effectIcon = "posterize"
            break
        case CameraImageProcessing.ColorFilterSepia:
            effectIcon = "sepia"
            break
        case CameraImageProcessing.ColorFilterSolarize:
            effectIcon = "solarize"
            break
        case CameraImageProcessing.ColorFilterWhiteboard:
            effectIcon = "whiteboard"
            break
        case CameraImageProcessing.ColorFilterEmboss:
            effectIcon = "emboss"
            break
        case CameraImageProcessing.ColorFilterSketch:
            effectIcon = "sketch"
            break
        case CameraImageProcessing.ColorFilterNeon:
            effectIcon = "neon"
            break
        default:
            effectIcon = "default"
            break
        }
        return "../pics/icon-m-effect-" + effectIcon + ".svg"
    }

    function sceneModeIcon(scene) {
        return "../pics/icon-m-scene_mode_" + modelExposure.iconName(
                    settings.mode.exposure) + ".svg"
    }

    function setMode(mode) {
        modelResolution.setMode(mode)
        settings.global.captureMode = mode
        settings.mode.path = settings.global.cameraId + "/" + mode
    }

    function hideAllPanels() {
        panelEffects.hide()
        panelExposure.hide()
        panelFlash.hide()
        panelFocus.hide()
        panelGeneral.hide()
        panelIso.hide()
        panelResolution.hide()
        panelWhiteBalance.hide()
        panelStorage.hide()
    }

    function restoreStorage() {
        // Restore selection to saved setting, fallback to internal otherwise
        for (var i = 0; i < modelStorage.rowCount; i++) {
            var name = modelStorage.getName(i)
            var path = modelStorage.getPath(i)
            if (path === settings.global.storagePath) {
                settings.global.storagePath = path
                console.log("Selecting", name, "->", path)
                return i
            }
        }
        console.log("Defaulting to internal storage")
        settings.global.storagePath = modelStorage.getPath(0)
    }

    Connections {
        target: modelStorage

        onModelReset: {
            restoreStorage()
        }
    }
}

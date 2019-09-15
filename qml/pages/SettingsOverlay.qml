import QtQuick 2.0
import QtQuick.Layouts 1.0
import QtMultimedia 5.4
import Sailfish.Silica 1.0
import uk.co.piggz.harbour_advanced_camera 1.0
import "../components/"

Item {
    anchors.fill: parent
    property int iconRotation: 0

    Item {
        id: buttonPanel
        opacity: (!panelEffects.expanded &&
                  !panelExposure.expanded &&
                  !panelFlash.expanded &&
                  !panelWhiteBalance.expanded &&
                  !panelFocus.expanded &&
                  !panelIso.expanded &&
                  !panelResolution.expanded &&
                  !panelGeneral.expanded) === true ? 1 : 0
        enabled: opacity > 0

        height: parent.height
        width: 2 * Theme.itemSizeSmall + 4 * Theme.paddingMedium
        anchors.left: parent.left
        anchors.top: parent.top

        Behavior on opacity { FadeAnimation {}}

        GridLayout {
            id: colButtons
            flow: GridLayout.TopToBottom
            rowSpacing: Theme.paddingSmall
            columnSpacing: Theme.paddingSmall
            rows: Math.floor(height / (btnScene.height + rowSpacing)) //using the button height and not theme size incase we change the RoundButton size

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

                onClicked: {
                    panelEffects.show();
                }
            }
            RoundButton {
                id: btnExposure
                image: sceneModeIcon()
                icon.color: Theme.primaryColor
                icon.rotation: iconRotation

                onClicked: {
                    panelExposure.show();
                }
            }
            RoundButton {
                id: btnFocus
                image: focusIcon()
                icon.rotation: iconRotation

                onClicked: {
                    panelFocus.show();
                }
            }
            RoundButton {
                id: btnResolution
                icon.color: Theme.primaryColor
                icon.rotation: iconRotation
                image: "../pics/icon-m-resolution.png"

                onClicked: {
                    panelResolution.show();
                }
            }
            RoundButton {
                id: btnWhiteBalance
                image: whiteBalanceIcon()
                icon.rotation: iconRotation

                onClicked: {
                    panelWhiteBalance.show();
                }
            }
            RoundButton {
                id: btnFlash
                image: flashIcon()
                icon.rotation: iconRotation

                onClicked: {
                    panelFlash.show();
                }
            }

            RoundButton {
                id: btnIso
                icon.color: Theme.primaryColor
                icon.rotation: iconRotation
                image: isoIcon()

                onClicked: {
                    panelIso.show();
                }
            }
            RoundButton {
                id: btnGeneral
                icon.color: Theme.primaryColor
                icon.rotation: iconRotation
                image: "image://theme/icon-m-developer-mode"

                onClicked: {
                    panelGeneral.show();
                }
            }

        }
    }

    DockedListView {
        id: panelEffects
        model: modelEffects
        selectedItem: settings.mode.effect
        rotation: iconRotation

        onClicked: {
            camera.imageProcessing.setColorFilter(value);
            settings.mode.effect = value;
            hide();
        }
    }

    DockedListView {
        id: panelExposure
        model: modelExposure
        selectedItem: settings.mode.exposure
        rotation: iconRotation

        onClicked: {
            camera.exposure.setExposureMode(value);
            settings.mode.exposure = value;
            hide();
        }
    }

    DockedListView {
        id: panelFlash
        model: modelFlash
        selectedItem: settings.mode.flash
        rotation: iconRotation

        onClicked: {
            camera.flash.setFlashMode(value);
            settings.mode.flash = value;
            hide();
        }
    }

    DockedListView {
        id: panelWhiteBalance
        model: modelWhiteBalance
        selectedItem: settings.mode.whiteBalance
        rotation: iconRotation

        onClicked: {
            camera.imageProcessing.setWhiteBalanceMode(value);
            settings.mode.whiteBalance = value;
            hide();
        }
    }

    DockedListView {
        id: panelFocus
        model: modelFocus
        selectedItem: settings.mode.focus
        rotation: iconRotation

        onClicked: {
            setFocusMode(value);
            hide();
        }
    }

    DockedListView {
        id: panelIso
        model: modelIso
        selectedItem: settings.mode.iso
        rotation: iconRotation

        onClicked: {
            if (value === 0) {
                camera.exposure.setAutoIsoSensitivity();
            } else {
                camera.exposure.setManualIsoSensitivity(value);
            }
            settings.mode.iso = value;
            hide();
        }
    }

    DockedListView {
        id: panelResolution
        model: sortedModelResolution
        selectedItem: settings.resolution(settings.global.captureMode)
        rotation: iconRotation

        onClicked: {
            settings.mode.resolution = settings.sizeToStr(value);
            hide();
            console.log("selected resolution", value, settings.mode.resolution);
            if (settings.global.captureMode == "video") {
                camera.videoRecorder.resolution = value;
            } else {
                camera.imageCapture.setResolution(value);
            }
        }
    }

    DockedPanel {
        id: panelGeneral
        modal: true
        animationDuration: 250
        width: parent.width / 2
        height: parent.height
        z: 99
        dock: Dock.Left
        clip: true
        rotation: iconRotation

        Rectangle {
            anchors.fill: parent
            color: Theme.colorScheme === Theme.LightOnDark ? "black" : "white"
            opacity: 0.7

            SilicaFlickable {
                anchors.fill: parent
                anchors.margins: Theme.paddingMedium
                contentHeight: mainColumn.height
                VerticalScrollDecorator {}
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
                            settings.global.swapZoomControl = checked;
                        }
                    }

                    ComboBox {
                        id: gridSwitch

                        property var grids: [{"id": "none", "name": qsTr("None")}, {"id": "thirds", "name": qsTr("Thirds")}, {"id": "ambience", "name": qsTr("Ambience")}]

                        function findIndex(id) {
                            for (var i = 0; i < grids.length; i++) {
                                if (grids[i]["id"] === id) {
                                    return i;
                                }
                            }
                            return 0;
                        }

                        label: qsTr("Grid:")
                        currentIndex: findIndex(settings.global.gridMode)

                        menu: ContextMenu {
                            Repeater {
                                model: gridSwitch.grids

                                delegate: MenuItem {
                                    text: modelData["name"]

                                    onClicked: {
                                        settings.global.gridMode = modelData["id"];
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
        modelExposure.setCamera(cam);
        modelEffects.setCamera(cam);
        modelIso.setCamera(cam);
        modelWhiteBalance.setCamera(cam);
        modelFocus.setCamera(cam);
        modelFlash.setCamera(cam);
        modelResolution.setImageCapture(cam.imageCapture);
        modelResolution.setVideoRecorder(cam.videoRecorder);
        modelResolution.setMode(settings.global.captureMode);
    }

    function flashIcon() {
        var flashIcon = "";
        switch(settings.mode.flash) {
        case Camera.FlashAuto:
            flashIcon = "image://theme/icon-camera-flash-automatic";
            break;
        case Camera.FlashOn:
            flashIcon = "image://theme/icon-camera-flash-on";
            break;
        case Camera.FlashOff:
            flashIcon = "image://theme/icon-camera-flash-off";
            break;
        case Camera.FlashRedEyeReduction:
            flashIcon = "image://theme/icon-camera-flash-redeye";
            break;
        default:
            flashIcon = "image://theme/icon-camera-flash-on";
            break;
        }
        return flashIcon;
    }

    function focusIcon() {
        var focusIcon = "";
        switch(settings.mode.focus) {
        case Camera.FocusAuto:
            focusIcon = "image://theme/icon-camera-focus-auto";
            break;
        case Camera.FocusManual:
            focusIcon = "../pics/icon-camera-focus-manual.png";
            break;
        case Camera.FocusMacro:
            focusIcon = "image://theme/icon-camera-focus-macro";
            break;
        case Camera.FocusHyperfocal:
            focusIcon = "../pics/icon-camera-focus-hyperfocal.png";
            break;
        case Camera.FocusContinuous:
            focusIcon = "../pics/icon-camera-focus-continuous.png";
            break;
        case Camera.FocusInfinity:
            focusIcon = "image://theme/icon-camera-focus-infinity";
            break;
        default:
            focusIcon = "image://theme/icon-camera-focus";
            break;
        }
        return focusIcon;
    }

    function whiteBalanceIcon() {
        var wbIcon = "";
        switch(settings.mode.whiteBalance) {
        case CameraImageProcessing.WhiteBalanceAuto:
            wbIcon = "image://theme/icon-camera-wb-automatic";
            break;
        case CameraImageProcessing.WhiteBalanceSunlight:
            wbIcon = "image://theme/icon-camera-wb-sunny";
            break;
        case CameraImageProcessing.WhiteBalanceCloudy:
            wbIcon = "image://theme/icon-camera-wb-cloudy";
            break;
        case CameraImageProcessing.WhiteBalanceShade:
            wbIcon = "image://theme/icon-camera-wb-shade";
            break;
        case CameraImageProcessing.WhiteBalanceTungsten:
            wbIcon = "image://theme/icon-camera-wb-tungsten";
            break;
        case CameraImageProcessing.WhiteBalanceFluorescent:
            wbIcon = "image://theme/icon-camera-wb-fluorecent";
            break;
        case CameraImageProcessing.WhiteBalanceSunset:
            wbIcon = "image://theme/icon-camera-wb-sunset";
            break;
        case CameraImageProcessing.WhiteBalanceFlash:
            wbIcon = "image://theme/icon-camera-wb-default"; //TODO need icon
            break;
        default:
            wbIcon = "image://theme/icon-camera-wb-default";
            break;
        }
        return wbIcon;
    }

    function isoIcon() {
        var iso = "";
        if (settings.mode.iso === 0) {
            iso = "../pics/icon-m-iso-auto.png";
        } else if (settings.mode.iso === 1) {
            iso = "../pics/icon-m-iso-hjr.png";
        } else {
            iso = "../pics/icon-m-iso-" + settings.mode.iso + ".png";
        }
        return iso;
    }

    function effectIcon() {
        var effectIcon = "";

        switch(settings.mode.effect) {
        case CameraImageProcessing.ColorFilterNone:
            effectIcon = "none";
            break;
        case CameraImageProcessing.ColorFilterAqua:
            effectIcon = "aqua";
            break;
        case CameraImageProcessing.ColorFilterBlackboard:
            effectIcon = "blackboard";
            break;
        case CameraImageProcessing.ColorFilterGrayscale:
            effectIcon = "grayscale";
            break;
        case CameraImageProcessing.ColorFilterNegative:
            effectIcon = "negative";
            break;
        case CameraImageProcessing.ColorFilterPosterize:
            effectIcon = "posterize";
            break;
        case CameraImageProcessing.ColorFilterSepia:
            effectIcon = "sepia";
            break;
        case CameraImageProcessing.ColorFilterSolarize:
            effectIcon = "solarize";
            break;
        case CameraImageProcessing.ColorFilterWhiteboard:
            effectIcon = "whiteboard";
            break;
        case 9: //CameraImageProcessing.ColorFilterEmboss: //TODO requires QT fix
            effectIcon = "emboss";
            break;
        case 10: //CameraImageProcessing.ColorFilterSketch:
            effectIcon = "sketch";
            break;
        case 11: //CameraImageProcessing.ColorFilterNeon:
            effectIcon = "neon";
            break;
        default:
            effectIcon = "default";
            break;
        }
        return "../pics/icon-m-effect-" + effectIcon + ".svg";
    }

    function sceneModeIcon(scene) {
        return "../pics/icon-m-scene_mode_" + modelExposure.iconName(settings.mode.exposure) + ".svg";
    }

    function setMode(mode, cam){
        modelResolution.setMode(mode);
        settings.global.captureMode = mode;
        settings.mode.path = settings.global.cameraId + "/" + mode;
    }
}

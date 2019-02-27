import QtQuick 2.0
import QtQuick.Layouts 1.0
import QtMultimedia 5.4
import Sailfish.Silica 1.0
import uk.co.piggz.harbour_advanced_camera 1.0
import "../components/"

Item {
    anchors.fill: parent

    Item {
        id: buttonPanel
        visible: true
        enabled: visible

        height: parent.height
        width: 2 * Theme.itemSizeSmall + 4 * Theme.paddingMedium
        anchors.left: parent.left
        anchors.top: parent.top

        Behavior on x {
            NumberAnimation { duration: 150 }
        }

        Row {
            spacing: Theme.paddingSmall
            anchors.fill: parent
            anchors.margins: Theme.paddingSmall

            ColumnLayout {
                id: colButtons
                spacing: Theme.paddingSmall
                width: Theme.itemSizeSmall
                
                RoundButton {
                    id: btnScene
                    icon.color: Theme.primaryColor
                    image: "../pics/icon-m-effect.png"

                    onClicked: {
                        hidePanels()
                        panelEffects.show();
                    }
                }
                RoundButton {
                    id: btnExposure
                    image: "image://theme/icon-camera-exposure-compensation"

                    onClicked: {
                        hidePanels()
                        panelExposure.show();
                    }
                }
                RoundButton {
                    id: btnFocus
                    image: focusIcon()

                    onClicked: {
                        hidePanels()
                        panelFocus.show();
                    }
                }
                RoundButton {
                    id: btnResolution
                    icon.color: Theme.primaryColor
                    image: "../pics/icon-m-resolution.png"

                    onClicked: {
                        hidePanels();
                        panelResolution.show();
                    }
                }
                RoundButton {
                    id: btnWhiteBalance
                    image: whiteBalanceIcon()

                    onClicked: {
                        hidePanels();
                        panelWhiteBalance.show();
                    }
                }
                RoundButton {
                    id: btnFlash
                    image: flashIcon()

                    onClicked: {
                        hidePanels();
                        panelFlash.show();
                    }
                }
            }
            ColumnLayout {
                id: colButtons2
                spacing: Theme.paddingSmall
                width: Theme.itemSizeSmall

                RoundButton {
                    id: btnIso
                    icon.color: Theme.primaryColor
                    image: isoIcon()

                    onClicked: {
                        hidePanels()
                        panelIso.show();
                    }
                }

            }
            /*
            Item {
                id: menuButtonContainer
                height: parent.height
                width: buttonPanel.buttonSize
                
                RoundButton {
                    id: btnMenu
                    height: buttonPanel.buttonSize
                    width: buttonPanel.buttonSize
                    anchors.verticalCenter: parent.verticalCenter
                    image: buttonPanel.menuVisible ? "image://theme/icon-m-left" : "image://theme/icon-m-right"
                    onClicked: {
                        buttonPanel.menuVisible = !buttonPanel.menuVisible;
                    }
                }
                

            }
            */
        }

    }

    DockedListView {
        id: panelEffects
        model: modelEffects
        selectedItem: settings.mode.effect

        onClicked: {
            camera.imageProcessing.setColorFilter(value);
            settings.mode.effect = value;
            hidePanels();
        }
    }

    DockedListView {
        id: panelExposure
        model: modelExposure
        selectedItem: settings.mode.exposure


        onClicked: {
            camera.exposure.setExposureMode(value);
            settings.mode.exposure = value;
            hidePanels();
        }
    }

    DockedListView {
        id: panelFlash
        model: modelFlash
        selectedItem: settings.mode.flash


        onClicked: {
            camera.flash.setFlashMode(value);
            settings.mode.flash = value;
            hidePanels();
        }
    }

    DockedListView {
        id: panelWhiteBalance
        model: modelWhiteBalance
        selectedItem: settings.mode.whiteBalance


        onClicked: {
            camera.imageProcessing.setWhiteBalanceMode(value);
            settings.mode.whiteBalance = value;
            hidePanels();
        }
    }

    DockedListView {
        id: panelFocus
        model: modelFocus
        selectedItem: settings.mode.focus

        onClicked: {
            setFocusMode(value);
            hidePanels();
        }
    }

    DockedListView {
        id: panelIso
        model: modelIso
        selectedItem: settings.mode.iso

        onClicked: {
            if (value === 0) {
                camera.exposure.setAutoIsoSensitivity();
            } else {
                camera.exposure.setManualIsoSensitivity(value);
            }
            settings.mode.iso = value;
            hidePanels();
        }
    }

    DockedListView {
        id: panelResolution
        model: sortedModelResolution
        selectedItem: settings.strToSize(temp_resolution_str)

        onClicked: {
            camera.imageCapture.setResolution(value);
            temp_resolution_str = settings.sizeToStr(value);
            settings.mode.resolution = temp_resolution_str;
            hidePanels();
            console.log("selected resolution", value, temp_resolution_str, settings.mode.resolution);
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

    Timer {
        id: delayQuery
        interval: 1000
        running: true
        repeat: false
        onTriggered: {
            modelExposure.setCamera(camera);
            modelEffects.setCamera(camera);
            modelIso.setCamera(camera);
            modelWhiteBalance.setCamera(camera);
            modelFocus.setCamera(camera);
            modelFlash.setCamera(camera);
            modelResolution.setImageCapture(camera.imageCapture);
        }
    }

    function hidePanels() {
        //buttonPanel.menuVisible = false;
        panelExposure.hide();
        panelEffects.hide();
        panelWhiteBalance.hide();
        panelFlash.hide();
        panelFocus.hide();
        panelIso.hide();
        panelResolution.hide();
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
}

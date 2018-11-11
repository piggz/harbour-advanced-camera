import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Media 1.0
import com.jolla.camera 1.0
import QtMultimedia 5.4
import QtQuick.Layouts 1.0
import uk.co.piggz.harbour_advanced_camera 1.0
import Nemo.Configuration 1.0
import "../components/"

Page {
    id: page

    // The effective value will be restricted by ApplicationWindow.allowedOrientations
    allowedOrientations: Orientation.Landscape

    ConfigurationValue {
        id: effectMode
        key: "/uk/co/piggz/harbour-advanced-camera/effectMode"
        defaultValue: ""
    }

    ConfigurationValue {
        id: exposureMode
        key: "/uk/co/piggz/harbour-advanced-camera/exposureMode"
        defaultValue: ""
    }

    ConfigurationValue {
        id: focusMode
        key: "/uk/co/piggz/harbour-advanced-camera/focusMode"
        defaultValue: ""
    }

    ConfigurationValue {
        id: resolution
        key: "/uk/co/piggz/harbour-advanced-camera/resolution"
        defaultValue: ""
    }

    ConfigurationValue {
        id: whiteBalanceMode
        key: "/uk/co/piggz/harbour-advanced-camera/whiteBalanceMode"
        defaultValue: ""
    }

    ConfigurationValue {
        id: flashMode
        key: "/uk/co/piggz/harbour-advanced-camera/flashMode"
        defaultValue: ""
    }

    ConfigurationValue {
        id: isoMode
        key: "/uk/co/piggz/harbour-advanced-camera/isoMode"
        defaultValue: ""
    }


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

    RoundButton {
        id: btnCapture

        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: 50


        height: parent.height / 6
        width: height

        image: "image://theme/icon-camera-shutter"

        onClicked: {
            camera.imageCapture.capture();
        }
    }

    Item {
        id: buttonPanel
        property int buttonSize: ((height -Theme.paddingMedium) / colButtons.children.length) - Theme.paddingMedium
        property bool menuVisible: true
        //color: "grey"
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
            anchors.margins: Theme.paddingMedium

            ColumnLayout {
                id: colButtons
                spacing: Theme.paddingMedium
                width: buttonPanel.buttonSize
                
                RoundButton {
                    id: btnScene
                    Layout.preferredHeight: buttonPanel.buttonSize
                    Layout.preferredWidth: buttonPanel.buttonSize
                    Layout.fillHeight: false
                    image: "../pics/icon-m-effect.png"

                    onClicked: {
                        hidePanels()
                        panelEffects.show();
                    }
                }
                RoundButton {
                    id: btnExposure
                    image: "image://theme/icon-camera-exposure-compensation"

                    Layout.preferredHeight: buttonPanel.buttonSize
                    Layout.preferredWidth: buttonPanel.buttonSize
                    Layout.fillHeight: false

                    onClicked: {
                        hidePanels()
                        panelExposure.show();
                    }
                }
                RoundButton {
                    id: btnFocus
                    image: "image://theme/icon-camera-focus"

                    Layout.preferredHeight: buttonPanel.buttonSize
                    Layout.preferredWidth: buttonPanel.buttonSize
                    Layout.fillHeight: false

                    onClicked: {
                        hidePanels()
                        panelFocus.show();
                    }
                }
                RoundButton {
                    id: btnResolution
                    Layout.preferredHeight: buttonPanel.buttonSize
                    Layout.preferredWidth: buttonPanel.buttonSize
                    Layout.fillHeight: false
                    image: "../pics/icon-m-resolution.png"

                    onClicked: {
                        hidePanels();
                        panelResolution.show();
                    }
                }
                RoundButton {
                    id: btnWhiteBalance
                    image: "image://theme/icon-camera-wb-automatic"

                    Layout.preferredHeight: buttonPanel.buttonSize
                    Layout.preferredWidth: buttonPanel.buttonSize
                    Layout.fillHeight: false

                    onClicked: {
                        hidePanels();
                        panelWhiteBalance.show();
                    }
                }
                RoundButton {
                    id: btnFlash
                    image: flashIcon()

                    Layout.preferredHeight: buttonPanel.buttonSize
                    Layout.preferredWidth: buttonPanel.buttonSize
                    Layout.fillHeight: false

                    onClicked: {
                        hidePanels();
                        panelFlash.show();
                    }
                }
            }
            ColumnLayout {
                id: colButtons2
                spacing: Theme.paddingMedium
                width: buttonPanel.buttonSize

                RoundButton {
                    id: btnIso
                    Layout.preferredHeight: buttonPanel.buttonSize
                    Layout.preferredWidth: buttonPanel.buttonSize
                    Layout.fillHeight: false
                    image: "image://theme/icon-camera-iso"

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
        selectedItem: effectMode.value

        onClicked: {
            camera.imageProcessing.setColorFilter(value);
            effectMode.value = value;
            hidePanels();
        }
    }

    DockedListView {
        id: panelExposure
        model: modelExposure
        selectedItem: exposureMode.value


        onClicked: {
            camera.exposure.setExposureMode(value);
            exposureMode.value = value;
            hidePanels();
        }
    }

    DockedListView {
        id: panelFlash
        model: modelFlash
        selectedItem: flashMode.value


        onClicked: {
            camera.flash.setFlashMode(value);
            flashMode.value = value;
            hidePanels();
        }
    }

    DockedListView {
        id: panelWhiteBalance
        model: modelWhiteBalance
        selectedItem: whiteBalanceMode.value


        onClicked: {
            camera.imageProcessing.setWhiteBalanceMode(value);
            whiteBalanceMode.value = value;
            hidePanels();
        }
    }

    DockedListView {
        id: panelFocus
        model: modelFocus
        selectedItem: focusMode.value

        onClicked: {
            camera.focus.setFocusMode(value);
            focusMode.value = value;
            hidePanels();
        }
    }

    DockedListView {
        id: panelIso
        model: modelIso
        selectedItem: isoMode.value

        onClicked: {
            if (value === 0) {
                camera.exposure.setAutoIsoSensitivity();
            } else {
                camera.exposure.setManualIsoSensitivity(value);
            }
            isoMode.value = value;
            hidePanels();
        }
    }

    DockedListView {
        id: panelResolution
        model: sortedModelResolution
        selectedItem: resolution.value

        onClicked: {
            camera.imageCapture.setResolution(value);
            resolution.value = value;
            hidePanels();
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

    /*ResolutionModel {
        id: modelResolution
    }*/

    ListModel {
        id: modelFlash

        ListElement {
            name: qsTr("Flash Auto")
            value: Camera.FlashAuto
        }

        ListElement {
            name: qsTr("Flash On")
            value: Camera.FlashOn
        }

        ListElement {
            name: qsTr("Red Eye Reduction")
            value: Camera.FlashRedEyeReduction
        }

        ListElement {
            name: qsTr("Flash Off")
            value: Camera.FlashOff
        }
    }

    ListModel {
        id: modelWhiteBalance

        ListElement {
            name: qsTr("Auto")
            value: CameraImageProcessing.WhiteBalanceAuto
        }

        ListElement {
            name: qsTr("Sunlight")
            value: CameraImageProcessing.WhiteBalanceSunlight
        }

        ListElement {
            name: qsTr("Cloudy")
            value: CameraImageProcessing.WhiteBalanceCloudy
        }

        ListElement {
            name: qsTr("Shade")
            value: CameraImageProcessing.WhiteBalanceShade
        }

        ListElement {
            name: qsTr("Tungsten")
            value: CameraImageProcessing.WhiteBalanceTungsten
        }

        ListElement {
            name: qsTr("Flourescent")
            value: CameraImageProcessing.WhiteBalanceFluorescent
        }

        ListElement {
            name: qsTr("Sunset")
            value: CameraImageProcessing.WhiteBalanceSunset
        }

        ListElement {
            name: qsTr("Flash")
            value: CameraImageProcessing.WhiteBalanceFlash
        }
    }


    ListModel {
        id: modelFocus

        ListElement {
            name: qsTr("Auto")
            value: Camera.FocusAuto
        }

        ListElement {
            name: qsTr("Manual")
            value: Camera.FocusManual
        }

        ListElement {
            name: qsTr("Hyperfocal")
            value: Camera.FocusHyperfocal
        }

        ListElement {
            name: qsTr("Infinity")
            value: Camera.FocusInfinity
        }

        ListElement {
            name: qsTr("Continuous")
            value: Camera.FocusContinuous
        }

        ListElement {
            name: qsTr("Macro")
            value: Camera.FocusMacro
        }
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

    Timer {
        id: delayQuery
        interval: 1000
        running: true
        repeat: false
        onTriggered: {
            modelExposure.setCamera(camera);
            modelEffects.setCamera(camera);
            modelIso.setCamera(camera);
            modelResolution.setImageCapture(camera.imageCapture);
        }
    }

    Component.onCompleted: {
        applySettings();
    }

    function applySettings() {
        camera.imageProcessing.setColorFilter(effectMode.value);
        camera.exposure.setExposureMode(exposureMode.value);
        camera.flash.setFlashMode(flashMode.value);
        camera.imageProcessing.setWhiteBalanceMode(whiteBalanceMode.value);
        camera.focus.setFocusMode(focusMode.value);

        if (isoMode.value === 0) {
            camera.exposure.setAutoIsoSensitivity();
        } else {
            camera.exposure.setManualIsoSensitivity(isoMode.value);
        }

        camera.imageCapture.setResolution(resolution.value);
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
        switch(flashMode.value) {
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
}

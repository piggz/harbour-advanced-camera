import QtQuick 2.0
import QtMultimedia 5.4
import Nemo.Configuration 1.0

Item {
    property alias global: globalSettings
    property alias mode: modeSettings
    property alias jollaCamera: jollaCameraSettings

    ConfigurationGroup {
        id: globalSettings
        path: "/uk/co/piggz/harbour-advanced-camera"
        property int cameraCount: 2
        property string cameraId: "primary"
        property string captureMode: "image"

        ConfigurationGroup {
            id: modeSettings
            path: globalSettings.cameraId + "/" + globalSettings.captureMode

            property int effect: CameraImageProcessing.ColorFilterNone
            property int exposure: Camera.ExposureManual
            property int flash: Camera.FlashOff
            property int focus: CameraFocus.FocusAuto
            property int iso: 0
            property string resolution: ""
            property int whiteBalance: CameraImageProcessing.WhiteBalanceAuto
        }
    }

    ConfigurationGroup {
        id: jollaCameraSettings
        path: "/apps/jolla-camera/" + globalSettings.cameraId + "/image"

        property string viewfinderResolution
        property string viewfinderResolution_16_9
        property string viewfinderResolution_4_3
    }

    function strToSize(siz) {
        console.log("Converting ", siz, " to size");

        var w = parseInt(siz.substring(0, siz.indexOf("x")));
        var h = parseInt(siz.substring(siz.indexOf("x") + 1));

        return Qt.size(w,h);
    }

    function sizeToStr(siz) {
        console.log("Converting ", siz, " to string");

        return siz.width + "x" + siz.height;
    }
}

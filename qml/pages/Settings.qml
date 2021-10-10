import QtQuick 2.0
import QtMultimedia 5.4
import Nemo.Configuration 1.0
import Sailfish.Silica 1.0

Item {
    property alias global: globalSettings
    property alias mode: modeSettings
    property alias jollaCamera: jollaCameraSettings

    property variant enabledCameras: [] //Calculated on startup and when disabledCameras changes

    ConfigurationGroup {
        id: globalSettings
        path: "/uk/co/piggz/harbour-advanced-camera"
        property int cameraCount: QtMultimedia.availableCameras.length
        property string cameraId: "0"
        property string captureMode: "image"
        property bool swapZoomControl: false
        property string gridMode: "none"
        property int videoBitrate: 12800000
        property int audioBitrate: 128000
        property string storagePath: StandardPaths.home
        property bool locationMetadata: true
        property bool enableWideCameraButtons: true
        property string disabledCameras: ""

        ConfigurationGroup {
            id: modeSettings
            path: globalSettings.cameraId + "/" + globalSettings.captureMode

            property int effect: CameraImageProcessing.ColorFilterNone
            property int exposure: Camera.ExposureManual
            property int flash: Camera.FlashOff
            property int focus: CameraFocus.FocusContinuous
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
        var w = parseInt(siz.substring(0, siz.indexOf("x")))
        var h = parseInt(siz.substring(siz.indexOf("x") + 1))
        return Qt.size(w, h)
    }

    function sizeToStr(siz) {
        return siz.width + "x" + siz.height
    }

    //Return either the current mode resolution or default resolution for that mode
    function resolution(mode) {
        if (settings.global.captureMode === mode
                && settings.mode.resolution !== "") {
            var res = strToSize(settings.mode.resolution)
            if (modelResolution.isValidResolution(res, mode)) {
                return res
            }
        }
        return modelResolution.defaultResolution(mode)
    }

    function calculateEnabledCameras()
    {
        settings.enabledCameras = []
        for (var i = 0; i < QtMultimedia.availableCameras.length; ++i) {
            if (settings.global.disabledCameras.indexOf("[" + QtMultimedia.availableCameras[i].deviceId + "]") == -1) {
                settings.enabledCameras.push(QtMultimedia.availableCameras[i].deviceId)
            }
        }
    }
}

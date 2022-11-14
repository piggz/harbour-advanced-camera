import QtQuick 2.0
import Sailfish.Silica 1.0
import QtMultimedia 5.6
import "pages"

ApplicationWindow {
    id: window
    property bool loadingComplete: false;
    Settings {
        id: settings
    }

    Rectangle {
        parent: window
        anchors.fill: parent
        z: -1
        color: "black"
    }

    VideoOutput {
        id: captureView
        source: cameraUI.camera
        width: window.width
        height: window.height
        z: -1
    }

    initialPage: CameraUI {
        id: cameraUI
    }

    allowedOrientations: Orientation.All
    cover: Qt.resolvedUrl("cover/CoverPage.qml")

    Component.onCompleted: {
        loadingComplete = true;
    }

    onApplicationActiveChanged: {
        if (Qt.application.state == Qt.ApplicationActive) {
            cameraUI.camera.start();
        } else {
            cameraUI.camera.stop();
        }
    }

    Keys.onPressed: {
        console.log(event.key);
        if (event.isAutoRepeat) {
            return
        }
        if (event.key === Qt.Key_VolumeUp) {
            cameraUI.volUp();
        } else if (event.key === Qt.Key_VolumeDown) {
            cameraUI.volDown();
        } else if (event.key === Qt.Key_Camera) {
            console.log("Cmamera key");
        }
    }
}

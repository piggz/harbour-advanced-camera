import QtQuick 2.0
import Sailfish.Silica 1.0
import uk.co.piggz.harbour_advanced_camera 1.0

Item {
    visible: settings.mode.gridMode != "none"

    function horizontalLines(id) {
        if (id === "thirds") return [0.33, 0.66];
        if (id === "ambiente") return [0.21, 0.79];
        return [];
    }

    function verticalLines(id) {
        if (id === "thirds") return [0.33, 0.66];
        if (id === "ambiente") return [0.2333, 0.7666];
        return [];
    }

    Repeater {
        model: horizontalLines(settings.mode.gridMode)

        delegate: Rectangle {
            width: parent.width
            height: 5
            y: parent.height * modelData

            color: "#88ffffff"
        }
    }

    Repeater {
        model: verticalLines(settings.mode.gridMode)

        delegate: Rectangle {
            width: 5
            height: parent.height
            x: parent.width * modelData

            color: "#88ffffff"
        }
    }
}

import QtQuick 2.0
import Sailfish.Silica 1.0

Item {
    id: root

    property double aspect: 16.0 / 9.0
    visible: settings.global.gridMode != "none"
    anchors.centerIn: parent
    width: parent.height * aspect
    height: parent.height

    function horizontalLines(id) {
        if (id === "thirds")
            return [0.33, 0.66]
        if (id === "ambience")
            return [0.21, 0.79]
        return []
    }

    function verticalLines(id) {
        if (id === "thirds")
            return [0.33, 0.66]
        if (id === "ambience")
            return [0.2333, 0.7666]
        return []
    }

    Repeater {
        model: horizontalLines(settings.global.gridMode)

        delegate: Item {
            width: parent.width
            height: 5

            Rectangle {
                id: left
                width: parent.width / 2
                height: 5
                y: root.height * modelData

                color: "#88ffffff"
            }

            OpacityRampEffect {
                sourceItem: left
                direction: OpacityRamp.RightToLeft
            }

            Rectangle {
                id: right
                width: parent.width / 2
                height: 5
                y: root.height * modelData
                x: root.width / 2

                color: "#88ffffff"
            }

            OpacityRampEffect {
                sourceItem: right
                direction: OpacityRamp.LeftToRight
            }
        }
    }

    Repeater {
        model: verticalLines(settings.global.gridMode)

        delegate: Item {
            width: 5
            height: parent.height

            Rectangle {
                id: up
                width: 5
                height: parent.height / 2
                x: root.width * modelData

                color: "#88ffffff"
            }

            OpacityRampEffect {
                sourceItem: up
                direction: OpacityRamp.BottomToTop
            }

            Rectangle {
                id: bottom
                width: 5
                height: parent.height / 2
                x: root.width * modelData
                y: up.height

                color: "#88ffffff"
            }

            OpacityRampEffect {
                sourceItem: bottom
                direction: OpacityRamp.TopToBottom
            }
        }
    }
}

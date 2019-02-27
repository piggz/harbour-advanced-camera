import QtQuick 2.0
import Sailfish.Silica 1.0

CoverBackground {
    TextArea {
        id: label
        anchors.centerIn: parent
        color: Theme.primaryColor
        font.bold: true
        horizontalAlignment: Text.AlignHCenter
        readOnly: true
        width: parent.width - 2 * Theme.paddingSmall
        text: qsTr("Advanced Camera")
    }
}

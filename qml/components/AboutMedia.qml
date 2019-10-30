import QtQuick 2.0
import QtQuick.Layouts 1.0
import Sailfish.Silica 1.0

Rectangle {
    id: mediaInfo
    color: "black"
    anchors.fill: parent

    property var file
    property var fileSize
    property var mediaModel
    property var mediaSize
    property var mediaDuration: ""

    SilicaListView {
        anchors.fill: parent
        anchors.margins: Theme.paddingSmall
        model: mediaModel
        header: PageHeader {
            title: file
            description: mediaDuration + "   " + mediaSize + "   " + fileSize
        }
        delegate: metaDelegate
        VerticalScrollDecorator {
        }
    }

    Component {
        id: metaDelegate
        Item {
            width: ListView.view.width
            height: Theme.itemSizeExtraSmall
            RowLayout {
                anchors.centerIn: parent
                Label {
                    text: name
                    anchors.right: parent.horizontalCenter
                    rightPadding: Theme.paddingMedium
                    color: Theme.secondaryColor
                    font.pixelSize: Theme.fontSizeSmall
                    Layout.fillWidth: true
                }
                Label {
                    text: value
                    anchors.left: parent.horizontalCenter
                    leftPadding: Theme.paddingMedium
                    color: Theme.primaryColor
                    font.pixelSize: Theme.fontSizeSmall
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                }
            }
        }
    }
}

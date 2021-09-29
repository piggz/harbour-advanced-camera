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
        DetailItem {
            label: qsTranslate("exifKey", model.name)
            value: model.value
        }
    }
}

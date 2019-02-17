import QtQuick 2.0
import Sailfish.Silica 1.0

DockedPanel {
    id: panel

    property alias model: listView.model
    property var selectedItem

    signal clicked(var value)

    width: parent.width / 2
    height: parent.height
    z: 99

    dock: Dock.Left
    clip:true

    SilicaListView {
        id: listView
        anchors.fill: parent
        VerticalScrollDecorator {}
        clip: true

        delegate: ListItem {
            width: ListView.view.width
            height: Theme.itemSizeSmall
            highlighted: value === selectedItem
            Rectangle {
                anchors.fill: parent
                color: "black"
                opacity: 0.7
                Label {
                    anchors {
                        left: parent.left
                        leftMargin: Theme.horizontalPageMargin
                        right: parent.right
                        rightMargin: Theme.horizontalPageMargin
                        verticalCenter: parent.verticalCenter
                    }
                    color: highlighted ? Theme.highlightColor : Theme.primaryColor
                    text: name
                }
            }
            onClicked: {
                panel.clicked(value);
            }
        }
    }
}

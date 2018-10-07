import QtQuick 2.0
import Sailfish.Silica 1.0

DockedPanel {
    id: panel

    property alias model: listView.model
    signal clicked(var value)

    width: parent.width / 2
    height: parent.height - buttonLayout.height - 40

    dock: Dock.Left
    clip:true

    SilicaListView {
        id: listView
        anchors.fill: parent
        anchors.margins: Theme.paddingMedium

        clip: true

        delegate: ListItem {
            width: ListView.view.width
            height: Theme.itemSizeSmall

            Label {
                text: name
            }
            onClicked: {
                panel.clicked(value);
            }

        }
    }
}

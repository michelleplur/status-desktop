import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Dialogs 1.3

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import StatusQ.Popups 0.1

import shared.controls.chat 1.0
import utils 1.0

Item {
    id: root

    property string label: ""
    property string colorId: ""
    property var colorHash
    property string image: ""
    property bool keycardCreatedAccount: false

    property StatusAssetSettings asset: StatusAssetSettings {
      name: "add"
    }

    signal clicked()

    width: parent.width
    height: 64
    Rectangle {
        anchors.fill: root
        color: sensor.containsMouse ? Theme.palette.statusSelect.menuItemHoverBackgroundColor : Theme.palette.statusSelect.menuItemBackgroundColor
    }

    MouseArea {
        id: sensor
        cursorShape: Qt.PointingHandCursor
        anchors.fill: root
        hoverEnabled: true

        onClicked: {
            root.clicked()
        }
    }

    Loader {
        id: userImageOrIcon
        sourceComponent: !!root.image.toString() || !!root.colorId ? userImage : addIcon
        anchors.leftMargin: Style.current.padding
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
    }

    Component {
        id: addIcon
        StatusRoundIcon {
            asset.name: root.asset.name
        }
    }

    Component {
        id: userImage
        UserImage {
            name: root.label
            image: root.image
            colorId: root.colorId
            colorHash: root.colorHash
            imageHeight: Constants.onboarding.userImageHeight
            imageWidth: Constants.onboarding.userImageWidth
        }
    }

    StatusBaseText {
        text: root.label
        font.pixelSize: 15
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: userImageOrIcon.right
        anchors.right: root.keycardCreatedAccount? keycardIcon.left : parent.right
        anchors.leftMargin: Style.current.padding
        color: !!root.colorId ? Theme.palette.directColor1 : Theme.palette.primaryColor1
        elide: Text.ElideRight
    }

    Loader {
        id: keycardIcon
        active: root.keycardCreatedAccount
        sourceComponent: keycardIconComponent
        anchors.rightMargin: Style.current.padding
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
    }

    Component {
        id: keycardIconComponent
        StatusIcon {
            icon: "keycard"
            height: Style.current.padding
            color: Theme.palette.baseColor1
        }
    }
}


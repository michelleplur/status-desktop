import QtQuick 2.12
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import QtQml.Models 2.3
import "../imports"
import "status"
import "./"

PopupMenu {
    id: root
    width: profileHeader.width
    closePolicy: Popup.CloseOnPressOutside | Popup.CloseOnEscape

    Item {
        id: profileHeader
        width: 200
        height: visible ? profileImage.height + username.height + viewProfileBtn.height + Style.current.padding * 2 : 0
        Rectangle {
            anchors.fill: parent
            visible: mouseArea.containsMouse
            color: Style.current.backgroundHover
        }
        StatusImageIdenticon {
            id: profileImage
            source: profileModel.profile.thumbnailImage || ""
            anchors.top: parent.top
            anchors.topMargin: 4
            anchors.horizontalCenter: parent.horizontalCenter
        }

        StyledText {
            id: username
            text: Utils.removeStatusEns(profileModel.ens.preferredUsername || profileModel.profile.username)
            elide: Text.ElideRight
            maximumLineCount: 3
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.Wrap
            anchors.top: profileImage.bottom
            anchors.topMargin: 4
            anchors.left: parent.left
            anchors.leftMargin: Style.current.smallPadding
            anchors.right: parent.right
            anchors.rightMargin: Style.current.smallPadding
            font.weight: Font.Medium
            font.pixelSize: 13
        }

        StyledText {
            id: viewProfileBtn
            text: qsTr("My profile →")
            horizontalAlignment: Text.AlignHCenter
            anchors.top: username.bottom
            anchors.topMargin: 4
            anchors.left: parent.left
            anchors.leftMargin: Style.current.smallPadding
            anchors.right: parent.right
            anchors.rightMargin: Style.current.smallPadding
            font.weight: Font.Medium
            font.pixelSize: 12
            color: Style.current.secondaryText
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                openProfilePopup(profileModel.profile.username, profileModel.profile.pubKey, profileModel.profile.thumbnailImage || "");
                root.close()
            }
        }
    }

    Separator {
        anchors.bottom: viewProfileAction.top
    }

    overrideTextColor: Style.current.textColor

    Action {
        text: qsTr("Online")
        onTriggered: {
            if (profileModel.profile.sendUserStatus != true) {
                profileModel.setSendUserStatus(true)
            }
            root.close()
        }
        icon.color: Style.current.green
        icon.source: "img/online.svg"
        icon.width: 16
        icon.height: 16
    }

    Action {
        text: qsTr("Offline")
        onTriggered: {
            if (profileModel.profile.sendUserStatus != false) {
                profileModel.setSendUserStatus(false)
            }
            root.close()
        }

        icon.color: Style.current.darkGrey
        icon.source: "img/offline.svg"
        icon.width: 16
        icon.height: 16
    }

}
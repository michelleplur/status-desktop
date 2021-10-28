import QtQuick 2.13
import QtQuick.Controls 2.13
import shared 1.0
import shared.panels 1.0

import utils 1.0

import StatusQ.Components 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core 0.1

Item {
    id: wrapper
    anchors.right: parent.right
    anchors.left: parent.left
    height: rectangle.height + 4

    property string publicKey: ""
    property string profilePubKey
    property var contactsList
    property string name: "channelName"
    property string lastSeen: ""
    property string identicon
    property int statusType: -1
    property bool hovered: false
    property bool enableMouseArea: true
    property bool isOnline: false
    property var currentTime
    property var messageContextMenu
    property color color: {
        if (wrapper.hovered) {
            return Style.current.menuBackgroundHover
        }
 return Style.current.transparent
    }
    //TODO remove dynamic scoping
    property string profileImage: appMain.getProfileImage(publicKey) || ""
    property bool isCurrentUser: (publicKey === profilePubKey)

    Rectangle {
        id: rectangle
        width: parent.width
        height: 40
        radius: 8
        color: wrapper.color
        Connections {
            enabled: !!wrapper.contactsList
            target: wrapper.contactsList
            onContactChanged: {
                if (pubkey === wrapper.publicKey) {
                    wrapper.profileImage = !!appMain.getProfileImage(wrapper.publicKey) ?
                                appMain.getProfileImage(wrapper.publicKey) : ""
                }
            }
        }

        StatusSmartIdenticon {
            id: contactImage
            anchors.left: parent.left
            anchors.leftMargin: Style.current.padding
            anchors.verticalCenter: parent.verticalCenter
            image: StatusImageSettings {
                width: 28
                height: 28
                source: wrapper.profileImage || wrapper.identicon
                isIdenticon: true
            }
            icon: StatusIconSettings {
                width: 28
                height: 28
                letterSize: 15
            }
            name: wrapper.name
        }

        StyledText {
            id: contactInfo
            text: Emoji.parse(Utils.removeStatusEns(Utils.filterXSS(wrapper.name))) + (isCurrentUser ? " " + qsTrId("(you)") : "")
            anchors.right: parent.right
            anchors.rightMargin: Style.current.smallPadding
            elide: Text.ElideRight
            color: Style.current.textColor
            font.weight: Font.Medium
            font.pixelSize: 15
            anchors.left: contactImage.right
            anchors.leftMargin: Style.current.halfPadding
            anchors.verticalCenter: parent.verticalCenter
        }

        StatusBadge {
            id: statusBadge
            width: 15
            height: 15
            anchors.left: contactImage.right
            anchors.leftMargin: -Style.current.smallPadding
            anchors.bottom: contactImage.bottom
            visible: wrapper.isOnline && !((statusType === -1) && (lastSeenMinutesAgo > 7))
            border.width: 3
            border.color: Theme.palette.statusAppNavBar.backgroundColor
            property real lastSeenMinutesAgo: ((currentTime/1000 - parseInt(lastSeen)) / 60);
            color: {
                if (visible) {
                    if (statusType === Constants.statusType_DoNotDisturb) {
                        return Style.current.red;
                    } else if (isCurrentUser || (lastSeenMinutesAgo < 5.5)) {
                        return Style.current.green;
                    } else if (((statusType !== -1) && (lastSeenMinutesAgo > 5.5)) ||
                               ((statusType === -1) && (lastSeenMinutesAgo < 7))) {
                        return Style.current.orange;
                    } else if ((statusType === -1) && (lastSeenMinutesAgo > 7)) {
                        return "transparent";
                    }
                } else {
                    return "transparent";
                }
            }
        }

        MouseArea {
            enabled: enableMouseArea
            cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            anchors.fill: parent
            hoverEnabled: true
            onEntered: {
                wrapper.hovered = true
            }
            onExited: {
                wrapper.hovered = false
            }
            onClicked: {
                if (mouse.button === Qt.LeftButton) {
                    //TODO remove dynamic scoping
                    openProfilePopup(wrapper.name, wrapper.publicKey, (wrapper.profileImage || wrapper.identicon), "", appMain.getUserNickname(wrapper.publicKey));
                }
                 else if (mouse.button === Qt.RightButton && !!messageContextMenu) {
                    // Set parent, X & Y positions for the messageContextMenu
                    messageContextMenu.parent = rectangle
                    messageContextMenu.setXPosition = function() { return 0}
                    messageContextMenu.setYPosition = function() { return rectangle.height}
                    messageContextMenu.isProfile = true;
                    messageContextMenu.show(wrapper.name, wrapper.publicKey, (wrapper.profileImage || wrapper.identicon), "", appMain.getUserNickname(wrapper.publicKey))
                }
            }
        }
    }
}
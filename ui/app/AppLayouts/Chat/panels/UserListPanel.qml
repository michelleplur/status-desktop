import QtQuick 2.13
import QtQuick.Controls 2.13

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1

import shared 1.0
import shared.panels 1.0
import shared.status 1.0
import utils 1.0

import "../controls"

import SortFilterProxyModel 0.2

Item {
    id: root
    anchors.fill: parent

    // Important:
    // Each chat/channel has its own ChatContentModule and each ChatContentModule has a single usersModule
    // usersModule on the backend contains everything needed for this component
    property var usersModule
    property var messageContextMenu
    property string label

    property var rootStore

    StatusBaseText {
        id: titleText
        anchors.top: parent.top
        anchors.topMargin: Style.current.padding
        anchors.left: parent.left
        anchors.leftMargin: Style.current.padding
        opacity: (root.width > 58) ? 1.0 : 0.0
        visible: (opacity > 0.1)
        font.pixelSize: Style.current.primaryTextFontSize
        font.weight: Font.Medium
        color: Theme.palette.directColor1
        text: root.label
    }

    StatusListView {
        id: userListView
        objectName: "userListPanel"

        anchors {
            top: titleText.bottom
            topMargin: Style.current.padding
            left: parent.left
            leftMargin: Style.current.halfPadding
            right: parent.right
            rightMargin: Style.current.halfPadding
            bottom: parent.bottom
            bottomMargin: Style.current.bigPadding
        }

        model: SortFilterProxyModel {
            sourceModel: usersModule.model
            sorters: [
                RoleSorter {
                    roleName: "onlineStatus"
                    sortOrder: Qt.DescendingOrder
                },
                StringSorter {
                    roleName: "displayName"
                    caseSensitivity: Qt.CaseInsensitive
                }
            ]
        }
        section.property: "onlineStatus"
        section.delegate: (root.width > 58) ? sectionDelegateComponent : null
        delegate: StatusMemberListItem {
            width: ListView.view.width
            nickName: model.localNickname
            userName: model.displayName !== "" ? model.displayName : model.alias
            pubKey: Utils.getCompressedPk(model.pubKey)
            isContact: model.isContact
            isVerified: model.isVerified
            isUntrustworthy: model.isUntrustworthy
            isAdmin: model.isAdmin
            asset.name: {
                const isCurrentUser = model.pubKey === root.rootStore.getPubkey()
                const visibility = Global.privacyModuleInst.profilePicturesVisibility

                if (isCurrentUser
                        || visibility === Constants.profilePicturesVisibility.everyone
                        || (visibility === Constants.profilePicturesVisibility.contactsOnly && model.isContact))
                    return model.icon

                return ""
            }
            asset.isImage: (asset.name !== "")
            asset.isLetterIdenticon: (asset.name === "")
            asset.color: Utils.colorForColorId(model.colorId)
            status: model.onlineStatus
            ringSettings.ringSpecModel: Utils.getColorHashAsJson(model.pubKey) // FIXME: use model.colorHash
            onClicked: {
                if (mouse.button === Qt.RightButton) {
                    // Set parent, X & Y positions for the messageContextMenu
                    messageContextMenu.parent = this
                    messageContextMenu.isProfile = true
                    messageContextMenu.myPublicKey = userProfile.pubKey
                    messageContextMenu.selectedUserPublicKey = model.pubKey
                    messageContextMenu.selectedUserDisplayName = model.displayName
                    messageContextMenu.selectedUserIcon = model.icon
                    messageContextMenu.popup(4, 4)
                } else if (mouse.button === Qt.LeftButton && !!messageContextMenu) {
                    Global.openProfilePopup(model.pubKey);
                }
            }
        }
    }

    Component {
        id: sectionDelegateComponent
        Item {
            width: parent.width
            height: 24
            StyledText {
                anchors.fill: parent
                anchors.leftMargin: Style.current.padding
                verticalAlignment: Text.AlignVCenter
                font.pixelSize: Style.current.additionalTextSize
                color: Theme.palette.baseColor1
                text: {
                    switch(parseInt(section)) {
                        case Constants.onlineStatus.online:
                            return qsTr("Online")
                        default:
                            return qsTr("Inactive")
                    }
                }
            }
        }
    }
}

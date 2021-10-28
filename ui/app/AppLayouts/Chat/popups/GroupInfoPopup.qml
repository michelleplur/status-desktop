import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13

import utils 1.0
import shared 1.0
import shared.views 1.0
import shared.panels 1.0
import shared.popups 1.0
import shared.status 1.0
import shared.controls 1.0

import StatusQ.Controls 0.1 as StatusQControls
import StatusQ.Components 0.1 as StatusQ

import "../panels"

// TODO: replace with StatusModal
ModalPopup {
    id: popup
    enum ChannelType {
        ActiveChannel,
        ContextChannel
    }
    property var store
    property bool addMembers: false
    property int currMemberCount: 1
    property int memberCount: 1
    readonly property int maxMembers: 10
    property var pubKeys: []
    property int channelType: GroupInfoPopup.ChannelType.ActiveChannel
    property QtObject channel
    property bool isAdmin: false
    property Component pinnedMessagesPopupComponent

    function resetSelectedMembers(){
        pubKeys = [];
        memberCount = channel.members.rowCount();
        currMemberCount = memberCount;
        contactList.membersData.clear();

        const contacts = getContactListObject()

        contacts.forEach(function (contact) {
            if(popup.channel.contains(contact.publicKey) ||
                    !contact.isContact) {
                return;
            }
            contactList.membersData.append(contact)
        })
    }

    onClosed: {
        popup.destroy();
    }

    onOpened: {
        addMembers = false;
        popup.isAdmin = popup.channel.isAdmin(popup.store.profileModelInst.profile.pubKey)
        btnSelectMembers.enabled = false;
        resetSelectedMembers();
    }

    function doAddMembers(){
        if(pubKeys.length === 0) return;
        chatsModel.groups.addMembers(popup.channel.id, JSON.stringify(pubKeys));
        popup.close();
    }

    header: Item {
      height: children[0].height
      width: parent.width


      StatusQ.StatusLetterIdenticon {
          id: letterIdenticon
          width: 36
          height: 36
          anchors.top: parent.top
          color: popup.channel.color
          name: popup.channel.name
      }
    
      StyledTextEdit {
          id: groupName
          //% "Add members"
          text: addMembers ? qsTrId("add-members") : popup.channel.name
          anchors.top: parent.top
          anchors.topMargin: 2
          anchors.left: letterIdenticon.right
          anchors.leftMargin: Style.current.smallPadding
          font.bold: true
          font.pixelSize: 14
          readOnly: true
          wrapMode: Text.WordWrap
      }

      StyledText {
          text: {
            let cnt = memberCount;
            if(addMembers){
                //% "%1 / 10 members"
                return qsTrId("%1-/-10-members").arg(cnt)
            } else {
                //% "%1 members"
                if(cnt > 1) return qsTrId("%1-members").arg(cnt);
                //% "1 member"
                return qsTrId("1-member");
            }
          }
          width: 160
          anchors.left: letterIdenticon.right
          anchors.leftMargin: Style.current.smallPadding
          anchors.top: groupName.bottom
          anchors.topMargin: 2
          font.pixelSize: 14
          color: Style.current.secondaryText
      }

      Rectangle {
            id: editGroupNameBtn
            visible: !addMembers && popup.isAdmin
            height: 24
            width: 24
            anchors.verticalCenter: groupName.verticalCenter
            anchors.leftMargin: Style.current.halfPadding
            anchors.left: groupName.right
            radius: 8

            SVGImage {
                id: editGroupImg
                source: Style.svg("edit-group")
                height: 16
                width: 16
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
            }

            MouseArea {
                id: closeModalMouseArea
                cursorShape: Qt.PointingHandCursor
                anchors.fill: parent
                hoverEnabled: true
                onExited: {
                    editGroupNameBtn.color = Style.current.white
                }
                onEntered: {
                    editGroupNameBtn.color = Style.current.grey
                }
                onClicked: renameGroupPopup.open()
            }
        }

        RenameGroupPopup {
            id: renameGroupPopup
            activeChannelName: popup.store.chatsModelInst.channelView.activeChannel.name
            onDoRename: {
                popup.store.chatsModelInst.groups.rename(groupName);
                close();
            }
        }
    }

    Item {
        id: addMembersItem
        anchors.fill: parent

        SearchBox {
            id: searchBox
            visible: addMembers
            iconWidth: 17
            iconHeight: 17
            customHeight: 44
            fontPixelSize: 15
        }

        NoFriendsRectangle {
            visible: contactList.membersData.count === 0 && memberCount === 0
            anchors.top: searchBox.bottom
            anchors.topMargin: Style.current.xlPadding
            anchors.horizontalCenter: parent.horizontalCenter
        }

        NoFriendsRectangle {
            visible: contactList.membersData.count === 0 && memberCount > 0
            width: 340
            //% "All your contacts are already in the group"
            text: qsTrId("group-chat-all-contacts-invited")
            textColor: Style.current.textColor
            anchors.top: searchBox.bottom
            anchors.topMargin: Style.current.xlPadding
            anchors.horizontalCenter: parent.horizontalCenter
        }

        ContactListPanel {
            id: contactList
            visible: addMembers && contactList.membersData.count > 0
            anchors.fill: parent
            anchors.topMargin: 50
            anchors.top: searchBox.bottom
            selectMode: memberCount < maxMembers
            searchString: searchBox.text.toLowerCase()
            onItemChecked: function(pubKey, itemChecked){
                var idx = pubKeys.indexOf(pubKey)
                if(itemChecked){
                    if(idx === -1){
                        pubKeys.push(pubKey)
                    }
                } else {
                    if(idx > -1){
                        pubKeys.splice(idx, 1);
                    }
                }
                memberCount = popup.channel.members.rowCount() + pubKeys.length;
                btnSelectMembers.enabled = pubKeys.length > 0
            }
        }
    }

    Item {
        id: groupInfoItem
        anchors.fill: parent

        Separator {
            id: separator
            visible: !addMembers
            anchors.left: parent.left
            anchors.leftMargin: -Style.current.padding
            anchors.right: parent.right
            anchors.rightMargin: -Style.current.padding
        }

        StatusSettingsLineButton {
            property int pinnedCount: popup.store.chatsModelInst.messageView.pinnedMessagesList.count

            id: pinnedMessagesBtn
            visible: pinnedCount > 0
            height: visible ? implicitHeight : 0
            //% "Pinned messages"
            text: qsTrId("pinned-messages")
            currentValue: pinnedCount
            anchors.top: separator.bottom
            anchors.topMargin: visible ? Style.current.halfPadding : 0
            anchors.leftMargin: 0
            anchors.rightMargin: 0
            onClicked: openPopup(pinnedMessagesPopupComponent)
            iconSource: Style.svg("pin")
        }

        Separator {
            id: separator2
            visible: pinnedMessagesBtn.visible
            anchors.left: parent.left
            anchors.leftMargin: -Style.current.padding
            anchors.right: parent.right
            anchors.rightMargin: -Style.current.padding
            anchors.top: pinnedMessagesBtn.bottom
            anchors.topMargin: visible ? Style.current.halfPadding : 0
        }

        Connections {
            target: popup.store.chatsModelInst.channelView
            onActiveChannelChanged: {
                if (popup.channelType === GroupInfoPopup.ChannelType.ActiveChannel) {
                    popup.channel = popup.store.chatsModelInst.channelView.activeChannel
                    resetSelectedMembers()
                }
            }
            onContextChannelChanged: {
                if (popup.channelType === GroupInfoPopup.ChannelType.ContextChannel) {
                    popup.channel = popup.store.chatsModelInst.channelView.contextChannel
                    resetSelectedMembers()
                }
            }
        }

        ListView {
            id: memberList
            anchors.top: separator2.bottom
            anchors.bottom: parent.bottom
            anchors.topMargin: addMembers ? 30 : Style.current.padding
            anchors.bottomMargin: Style.current.padding
            anchors.left: parent.left
            anchors.leftMargin: Style.current.padding
            anchors.right: parent.right
            anchors.rightMargin: Style.current.padding
            spacing: Style.current.padding
            Layout.fillWidth: true
            Layout.fillHeight: true
            model: popup.channel.members
            delegate: Item {
                id: contactRow
                width: parent.width
                height: identicon.height

                property string nickname: appMain.getUserNickname(model.publicKey)

                StatusQ.StatusSmartIdenticon {
                    id: identicon
                    anchors.left: parent.left
                    image.source: appMain.getProfileImage(model.publicKey)|| model.identicon
                    image.isIdenticon: true
                }

                StyledText {
                    text: !model.userName.endsWith(".eth") && !!contactRow.nickname ?
                              contactRow.nickname : Utils.removeStatusEns(model.userName)
                    anchors.left: identicon.right
                    anchors.leftMargin: Style.current.padding
                    anchors.verticalCenter: parent.verticalCenter
                    font.pixelSize: 17

                    StyledText {
                        visible: model.publicKey === profileModel.profile.pubKey
                        anchors.left: parent.right
                        anchors.leftMargin: 5
                        //% "(You)"
                        text: qsTrId("-you-")
                        color: Style.current.secondaryText
                        font.pixelSize: parent.font.pixelSize
                    }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            const userProfileImage = appMain.getProfileImage(model.publicKey)
                            openProfilePopup(model.userName, model.publicKey, userProfileImage || model.identicon, '', contactRow.nickname, popup)
                        }
                    }
                }

                StyledText {
                    id: adminLabel
                    visible: model.isAdmin
                    //% "Admin"
                    text: qsTrId("group-chat-admin")
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    font.pixelSize: 13
                    color: Style.current.secondaryText
                }

                StyledText {
                    id: moreActionsBtn
                    visible: !model.isAdmin && popup.isAdmin
                    text: "..."
                    anchors.right: parent.right
                    anchors.rightMargin: Style.current.smallPadding
                    anchors.verticalCenter: parent.verticalCenter
                    font.pixelSize: 20
                    font.bold: true
                    color: Style.current.secondaryText
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            contextMenu.popup(-contextMenu.width / 2 + moreActionsBtn.width / 2, moreActionsBtn.height + 10)
                        }
                        cursorShape: Qt.PointingHandCursor
                        // TODO: replace with StatusPopupMenu
                        PopupMenu {
                            id: contextMenu
                            Action {
                                icon.source: Style.svg("make-admin")
                                icon.width: 16
                                icon.height: 16
                                //% "Make Admin"
                                text: qsTrId("make-admin")
                                onTriggered: popup.store.chatsModelInst.groups.makeAdmin(popup.channel.id,  model.publicKey)
                            }
                            Action {
                                icon.source: Style.svg("remove-from-group")
                                icon.width: 16
                                icon.height: 16
                                icon.color: Style.current.red
                                //% "Remove From Group"
                                text: qsTrId("remove-from-group")
                                onTriggered: popup.store.chatsModelInst.groups.kickMember(popup.channel.id,  model.publicKey)
                            }
                        }
                    }
                }
            }
        }
    }

    footer: Item {
        visible: popup.isAdmin
        width: parent.width
        height: children[0].height
        StatusQControls.StatusButton {
          visible: !addMembers
          anchors.right: parent.right
          //% "Add members"
          text: qsTrId("add-members")
          anchors.bottom: parent.bottom
          onClicked: {
            addMembers = true;
          }
        }

        StatusQControls.StatusRoundButton {
            id: btnBack
            visible: addMembers
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            icon.name: "arrow-right"
            icon.width: 20
            icon.height: 16
            icon.rotation: 180
            onClicked : {
                addMembers = false;
                resetSelectedMembers();
            }
        }

        StatusQControls.StatusButton {
          id: btnSelectMembers
          visible: addMembers
          enabled: memberCount >= currMemberCount
          anchors.right: parent.right
          //% "Add selected"
          text: qsTrId("add-selected")
          anchors.bottom: parent.bottom
          onClicked: doAddMembers()
        }
    }

    content: addMembers ? addMembersItem : groupInfoItem
}
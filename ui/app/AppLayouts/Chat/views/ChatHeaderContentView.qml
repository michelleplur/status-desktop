import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.13

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1

import utils 1.0

import "../panels"

RowLayout {
    id: root
    spacing: padding / 2

    property alias menuButton: menuButton
    property alias membersButton: membersButton
    property alias searchButton: searchButton

    property var rootStore
    property var chatContentModule: root.rootStore.currentChatContentModule()
    property int padding: 8

    signal searchButtonClicked()

    Loader {
        id: loader
        sourceComponent: statusChatInfoButton
        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.alignment: Qt.AlignLeft
        Layout.leftMargin: padding
    }

    RowLayout {
        id: actionButtons
        Layout.alignment: Qt.AlignRight
        Layout.rightMargin: padding
        spacing: 8

        StatusFlatRoundButton {
            id: searchButton
            icon.name: "search"
            type: StatusFlatRoundButton.Type.Secondary
            onClicked: root.searchButtonClicked()

            // initializing the tooltip
            tooltip.text: qsTr("Search")
            tooltip.orientation: StatusToolTip.Orientation.Bottom
            tooltip.y: parent.height + 12
        }

        StatusFlatRoundButton {
            id: membersButton
            visible: {
                if(!chatContentModule || chatContentModule.chatDetails.type === Constants.chatType.publicChat)
                    return false

                return localAccountSensitiveSettings.showOnlineUsers &&
                        chatContentModule.chatDetails.isUsersListAvailable
            }
            highlighted: localAccountSensitiveSettings.expandUsersList
            icon.name: "group-chat"
            type: StatusFlatRoundButton.Type.Secondary
            onClicked: {
                localAccountSensitiveSettings.expandUsersList = !localAccountSensitiveSettings.expandUsersList;
            }
            // initializing the tooltip
            tooltip.text: qsTr("Members")
            tooltip.orientation: StatusToolTip.Orientation.Bottom
            tooltip.y: parent.height + 12
        }

        StatusFlatRoundButton {
            id: menuButton
            objectName: "chatToolbarMoreOptionsButton"
            icon.name: "more"
            type: StatusFlatRoundButton.Type.Secondary

            // initializing the tooltip
            tooltip.visible: !!tooltip.text && menuButton.hovered && !contextMenu.opened
            tooltip.text: qsTr("More")
            tooltip.orientation: StatusToolTip.Orientation.Bottom
            tooltip.y: parent.height + 12

            property bool showMoreMenu: false
            onClicked: {
                menuButton.highlighted = true

                let originalOpenHandler = contextMenu.openHandler
                let originalCloseHandler = contextMenu.closeHandler

                contextMenu.openHandler = function () {
                    if (!!originalOpenHandler) {
                        originalOpenHandler()
                    }
                }

                contextMenu.closeHandler = function () {
                    menuButton.highlighted = false
                    if (!!originalCloseHandler) {
                        originalCloseHandler()
                    }
                }

                contextMenu.openHandler = originalOpenHandler
                contextMenu.popup(-contextMenu.width + menuButton.width, menuButton.height + 4)
            }

            ChatContextMenuView {
                id: contextMenu
                objectName: "moreOptionsContextMenu"
                emojiPopup: root.emojiPopup
                openHandler: function () {
                    if(!chatContentModule) {
                        console.debug("error on open chat context menu handler - chat content module is not set")
                        return
                    }
                    currentFleet = chatContentModule.getCurrentFleet()
                    isCommunityChat = chatContentModule.chatDetails.belongsToCommunity
                    amIChatAdmin = chatContentModule.amIChatAdmin()
                    chatId = chatContentModule.chatDetails.id
                    chatName = chatContentModule.chatDetails.name
                    chatDescription = chatContentModule.chatDetails.description
                    chatEmoji = chatContentModule.chatDetails.emoji
                    chatColor = chatContentModule.chatDetails.color
                    chatType = chatContentModule.chatDetails.type
                    chatMuted = chatContentModule.chatDetails.muted
                    channelPosition = chatContentModule.chatDetails.position
                }

                onMuteChat: {
                    if(!chatContentModule) {
                        console.debug("error on mute chat from context menu - chat content module is not set")
                        return
                    }
                    chatContentModule.muteChat()
                }

                onUnmuteChat: {
                    if(!chatContentModule) {
                        console.debug("error on unmute chat from context menu - chat content module is not set")
                        return
                    }
                    chatContentModule.unmuteChat()
                }

                onMarkAllMessagesRead: {
                    if(!chatContentModule) {
                        console.debug("error on mark all messages read from context menu - chat content module is not set")
                        return
                    }
                    chatContentModule.markAllMessagesRead()
                }

                onClearChatHistory: {
                    if(!chatContentModule) {
                        console.debug("error on clear chat history from context menu - chat content module is not set")
                        return
                    }
                    chatContentModule.clearChatHistory()
                }

                onRequestAllHistoricMessages: {
                    // Not Refactored Yet - Check in the `master` branch if this is applicable here.
                }

                onLeaveChat: {
                    if(!chatContentModule) {
                        console.debug("error on leave chat from context menu - chat content module is not set")
                        return
                    }
                    chatContentModule.leaveChat()
                }

                onDeleteCommunityChat: root.rootStore.removeCommunityChat(chatId)

                onDownloadMessages: {
                    if(!chatContentModule) {
                        console.debug("error on leave chat from context menu - chat content module is not set")
                        return
                    }
                    chatContentModule.downloadMessages(file)
                }

                onDisplayProfilePopup: {
                    Global.openProfilePopup(publicKey)
                }

                onDisplayGroupInfoPopup: {
                    Global.openPopup(root.rootStore.groupInfoPopupComponent, {
                                         chatContentModule: chatContentModule,
                                         chatDetails: chatContentModule.chatDetails
                                     })
                }

                onEditCommunityChannel: {
                    root.rootStore.editCommunityChannel(
                                chatId,
                                newName,
                                newDescription,
                                newEmoji,
                                newColor,
                                newCategory,
                                channelPosition // TODO change this to the signal once it is modifiable
                                )
                }
                onAddRemoveGroupMember: {
                    loader.sourceComponent = contactsSelector
                }
                onFetchMoreMessages: {
                    root.rootStore.messageStore.requestMoreMessages();
                }
                onLeaveGroup: {
                    chatContentModule.leaveChat();
                }
                onUpdateGroupChatDetails: {
                    root.rootStore.chatCommunitySectionModule.updateGroupChatDetails(
                                chatId,
                                groupName,
                                groupColor,
                                groupImage
                                )
                }
            }
        }

        Rectangle {
            implicitWidth: 1
            implicitHeight: 24
            color: Theme.palette.directColor7
            Layout.alignment: Qt.AlignVCenter
            visible: (menuButton.visible || membersButton.visible || searchButton.visible)
        }
    }

    Keys.onEscapePressed: { loader.sourceComponent = statusChatInfoButton }

    // Chat toolbar content option 1:
    Component {
        id: statusChatInfoButton

        StatusChatInfoButton {
            objectName: "chatInfoBtnInHeader"
            width: Math.min(implicitWidth, parent.width)
            title: chatContentModule? chatContentModule.chatDetails.name : ""
            subTitle: {
                if(!chatContentModule)
                    return ""

                // In some moment in future this should be part of the backend logic.
                // (once we add transaltion on the backend side)
                switch (chatContentModule.chatDetails.type) {
                case Constants.chatType.oneToOne:
                    return (chatContentModule.isMyContact(chatContentModule.chatDetails.id) ?
                                qsTr("Contact") :
                                qsTr("Not a contact"))
                case Constants.chatType.publicChat:
                    return qsTr("Public chat")
                case Constants.chatType.privateGroupChat:
                    let cnt = root.usersStore.usersModule.model.count
                    if(cnt > 1) return qsTr("%n member(s)", "", cnt);
                    return qsTr("1 member");
                case Constants.chatType.communityChat:
                    return Utils.linkifyAndXSS(chatContentModule.chatDetails.description).trim()
                default:
                    return ""
                }
            }
            image.source: chatContentModule? chatContentModule.chatDetails.icon : ""
            ringSettings.ringSpecModel: chatContentModule && chatContentModule.chatDetails.type === Constants.chatType.oneToOne ?
                                            Utils.getColorHashAsJson(chatContentModule.chatDetails.id) : ""
            icon.color: chatContentModule?
                            chatContentModule.chatDetails.type === Constants.chatType.oneToOne ?
                                Utils.colorForPubkey(chatContentModule.chatDetails.id)
                              : chatContentModule.chatDetails.color
            : ""
            icon.emoji: chatContentModule? chatContentModule.chatDetails.emoji : ""
            icon.emojiSize: "24x24"
            type: chatContentModule? chatContentModule.chatDetails.type : Constants.chatType.unknown
            pinnedMessagesCount: chatContentModule? chatContentModule.pinnedMessagesModel.count : 0
            muted: chatContentModule? chatContentModule.chatDetails.muted : false

            onPinnedMessagesCountClicked: {
                if(!chatContentModule) {
                    console.debug("error on open pinned messages - chat content module is not set")
                    return
                }
                Global.openPopup(pinnedMessagesPopupComponent, {
                                     store: rootStore,
                                     messageStore: messageStore,
                                     pinnedMessagesModel: chatContentModule.pinnedMessagesModel,
                                     messageToPin: ""
                                 })
            }
            onUnmute: {
                if(!chatContentModule) {
                    console.debug("error on unmute chat - chat content module is not set")
                    return
                }
                chatContentModule.unmuteChat()
            }

            sensor.enabled: {
                if(!chatContentModule)
                    return false

                return chatContentModule.chatDetails.type !== Constants.chatType.publicChat &&
                        chatContentModule.chatDetails.type !== Constants.chatType.communityChat
            }
            onClicked: {
                switch (chatContentModule.chatDetails.type) {
                case Constants.chatType.privateGroupChat:
                    Global.openPopup(root.rootStore.groupInfoPopupComponent, {
                                         chatContentModule: chatContentModule,
                                         chatDetails: chatContentModule.chatDetails
                                     })
                    break;
                case Constants.chatType.oneToOne:
                    Global.openProfilePopup(chatContentModule.chatDetails.id)
                    break;
                }
            }
        }
    }

    // Chat toolbar content option 2:
    Component {
        id: contactsSelector
        GroupChatPanel {
            sectionModule: root.chatSectionModule
            chatContentModule: root.chatContentModule
            rootStore: root.rootStore
            maxHeight: root.height
            onPanelClosed: loader.sourceComponent = statusChatInfoButton
        }
    }
}
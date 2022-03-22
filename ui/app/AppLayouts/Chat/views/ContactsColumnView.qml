import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13


import utils 1.0
import shared 1.0

import "../panels"
import "../popups"
import "../popups/community"

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Popups 0.1

Item {
    id: root
    width: 304
    height: parent.height

    // Important:
    // We're here in case of ChatSection
    // This module is set from `ChatLayout` (each `ChatLayout` has its own chatSectionModule)
    property var chatSectionModule

    property var store
    property var contactsStore
    property var emojiPopup

    // Not Refactored Yet
    //property int chatGroupsListViewCount: channelList.model.count
    signal openProfileClicked()
    signal openAppSearch()

    Component.onCompleted: {
        appMain.openContactsPopup.connect(function(){
            Global.openPopup(contactRequestsPopup, {chatSectionModule})
        })
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            //steal focus from search field
            actionButton.forceActiveFocus();
        }
    }

    StatusNavigationPanelHeadline {
        id: headline
        anchors.top: parent.top
        anchors.topMargin: 16
        anchors.horizontalCenter: parent.horizontalCenter
        //% "Chat"
        text: qsTrId("chat")
    }

    RowLayout {
        id: searchInputWrapper
        width: parent.width
        height: searchInput.height
        anchors.top: headline.bottom
        anchors.topMargin: 16
        anchors.right: parent.right
        anchors.rightMargin: 8


        StatusBaseInput {
            id: searchInput
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
            Layout.leftMargin: 17
            implicitHeight: 36
            topPadding: 9
            //% "Search"
            placeholderText: qsTrId("search")
            icon.name: "search"
            MouseArea {
                anchors.fill: parent
                onClicked: root.openAppSearch()
            }
        }

        StatusIconTabButton {
            icon.name: "public-chat"
            onClicked: { publicChatCommunityContextMenu.popup(); }
            StatusPopupMenu {
                 id: publicChatCommunityContextMenu
                 closePolicy: Popup.CloseOnReleaseOutsideParent | Popup.CloseOnEscape
                 StatusMenuItem {
                     //% "Join public chat"
                     text: qsTrId("new-public-group-chat")
                     icon.name: "public-chat"
                     onTriggered: Global.openPopup(publicChatPopupComponent)
                 }

                 StatusMenuItem {
                     //% "Communities"
                     text: qsTrId("communities")
                     icon.name: "communities"
                     onTriggered: Global.openPopup(communitiesPopupComponent)
                     enabled: localAccountSensitiveSettings.communitiesEnabled
                 }
             }
        }


        StatusIconTabButton {
            icon.name: "edit"
            onClicked: {
                root.store.openCreateChat = !root.store.openCreateChat;
            }
        }
    }


    StatusContactRequestsIndicatorListItem {
        id: contactRequests

        property int nbRequests: root.store.contactRequestsModel.count

        anchors.top: searchInputWrapper.bottom
        anchors.topMargin: visible ? Style.current.padding : 0
        anchors.horizontalCenter: parent.horizontalCenter

        visible: nbRequests > 0
        height: visible ? implicitHeight : 0

        //% "Contact requests"
        title: qsTrId("contact-requests")
        requestsCount: nbRequests

        sensor.onClicked: Global.openPopup(contactRequestsPopup)
    }

    ScrollView {
        id: chatGroupsContainer

        width: parent.width
        height: (contentHeight < (parent.height - contactRequests.height - Style.current.padding)) ? contentHeight : (parent.height - contactRequests.height - Style.current.padding)
        anchors.top: contactRequests.bottom
        anchors.topMargin: Style.current.padding
        anchors.bottom: root.bottom
        contentHeight: channelList.childrenRect.height + emptyViewAndSuggestions.childrenRect.height
        anchors.horizontalCenter: parent.horizontalCenter

        leftPadding: Style.current.halfPadding
        rightPadding: Style.current.halfPadding

        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

        clip: true

        StatusChatList {
            id: channelList

            model: root.chatSectionModule.model
            onChatItemSelected: {
                root.chatSectionModule.setActiveItem(id, "")
            }
            onChatItemUnmuted: root.chatSectionModule.unmuteChat(id)

            popupMenu: ChatContextMenuView {
                id: chatContextMenuView
                emojiPopup: root.emojiPopup

                openHandler: function (id) {
                    let jsonObj = root.chatSectionModule.getItemAsJson(id)
                    let obj = JSON.parse(jsonObj)
                    if (obj.error) {
                        console.error("error parsing chat item json object, id: ", id, " error: ", obj.error)
                        close()
                        return
                    }

                    currentFleet = root.chatSectionModule.getCurrentFleet()
                    isCommunityChat = root.chatSectionModule.isCommunity()
                    amIChatAdmin = obj.amIChatAdmin
                    chatId = obj.itemId
                    chatName = obj.name
                    chatDescription = obj.description
                    chatEmoji = obj.emoji
                    chatColor = obj.color
                    chatType = obj.type
                    chatMuted = obj.muted
                }

                onMuteChat: {
                    root.chatSectionModule.muteChat(chatId)
                }

                onUnmuteChat: {
                    root.chatSectionModule.unmuteChat(chatId)
                }

                onMarkAllMessagesRead: {
                    root.chatSectionModule.markAllMessagesRead(chatId)
                }

                onClearChatHistory: {
                    root.chatSectionModule.clearChatHistory(chatId)
                }

                onRequestAllHistoricMessages: {
                    // Not Refactored Yet - Check in the `master` branch if this is applicable here.
                }

                onLeaveChat: {
                    root.chatSectionModule.leaveChat(chatId)
                }

                onDeleteCommunityChat: {
                    // Not Refactored Yet
                }

                onDownloadMessages: {
                    // Not Refactored Yet
                }

                onDisplayProfilePopup: {
                    Global.openProfilePopup(publicKey)
                }
                onLeaveGroup: {
                    chatSectionModule.leaveChat("", chatId, true);
                }
                onDisplayGroupInfoPopup: {
                    chatSectionModule.prepareChatContentModuleForChatId(chatId)
                    let chatContentModule = chatSectionModule.getChatContentModule()
                    Global.openPopup(groupInfoPopupComponent, {
                                         chatContentModule: chatContentModule,
                                         chatDetails: chatContentModule.chatDetails
                                     })
                }
            }
        }

        EmptyViewPanel {
            id: emptyViewAndSuggestions
            visible: !localAccountSensitiveSettings.hideChannelSuggestions
            width: parent.width
            anchors.top: channelList.bottom
            anchors.topMargin: Style.current.padding
            rootStore: root.store
            onSuggestedMessageClicked: chatSectionModule.createPublicChat(channel)
        }
    }

    Component {
        id: publicChatPopupComponent
        PublicChatPopup {
            onJoinPublicChat: {
                chatSectionModule.createPublicChat(name)
            }
            onSuggestedMessageClicked: {
                chatSectionModule.createPublicChat(channel)
            }

            onClosed: {
                destroy()
            }
        }
    }

    Component {
        id: privateChatPopupComponent
        PrivateChatPopup {
            store: root.store
            contactsStore: root.contactsStore
            onJoinPrivateChat: {
                chatSectionModule.createOneToOneChat("", publicKey, ensName)
            }
            onClosed: {
                destroy()
            }
            onProfileClicked: {
                root.openProfileClicked();
            }
        }
    }

    Component {
        id: communitiesPopupComponent
        CommunitiesPopup {
            anchors.centerIn: parent
            communitiesList: root.store.communitiesList
            onSetActiveCommunity: {
                root.store.setActiveCommunity(id)
            }
            onSetObservedCommunity: {
                root.store.setObservedCommunity(id)
            }
            onClosed: {
                destroy()
            }
        }
    }

    Component {
        id: createCommunitiesPopupComponent
        CreateCommunityPopup {
            anchors.centerIn: parent
            store: root.store
            onClosed: {
                destroy()
            }
        }
    }

    Component {
        id: importCommunitiesPopupComponent
        AccessExistingCommunityPopup {
            anchors.centerIn: parent
            store: root.store
            onClosed: {
                destroy()
            }
        }
    }

    Component {
        id: communityDetailPopup
        CommunityDetailPopup {
            anchors.centerIn: parent
            store: root.store
            onClosed: {
                destroy()
            }
        }
    }

    Component {
        id: contactRequestsPopup
        ContactRequestsPopup {
            store: root.store
            onClosed: {
                destroy()
            }
        }
    }

    Connections {
        target: root.store.communitiesModuleInst
        onImportingCommunityStateChanged: {
            if (state !== Constants.communityImported &&
                state !== Constants.communityImportingInProgress &&
                state !== Constants.communityImportingError)
            {
                return
            }

            Global.toastMessage.close()

            if (state === Constants.communityImported)
            {
                //% "Community imported"
                Global.toastMessage.title = qsTrId("community-imported")
                Global.toastMessage.source = ""
                Global.toastMessage.iconRotates = false
                Global.toastMessage.dissapearInMs = 4000
            }
            else if (state === Constants.communityImportingInProgress)
            {
                //% "Importing community is in progress"
                Global.toastMessage.title = qsTrId("importing-community-is-in-progress")
                Global.toastMessage.source = Style.svg("loading")
                Global.toastMessage.iconRotates = true
                Global.toastMessage.dissapearInMs = -1
            }
            else if (state === Constants.communityImportingError)
            {
                Global.toastMessage.title = errorMsg
                Global.toastMessage.source = ""
                Global.toastMessage.iconRotates = false
                Global.toastMessage.dissapearInMs = 4000
            }

            Global.toastMessage.displayCloseButton = false
            Global.toastMessage.displayLink = false
            Global.toastMessage.iconColor = Style.current.primary
            Global.toastMessage.open()
        }
    }

    Connections {
        target: root.store.mainModuleInst

        onOpenContactRequestsPopup:{
            Global.openPopup(contactRequestsPopup)
        }
    }
}

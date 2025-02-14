import QtQuick 2.13

import utils 1.0
import shared.panels 1.0
import shared.status 1.0
import shared.controls 1.0
import shared.popups 1.0
import shared.panels.chat 1.0
import shared.views.chat 1.0
import shared.controls.chat 1.0

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1 as StatusQUtils
import StatusQ.Controls 0.1
import StatusQ.Components 0.1

Loader {
    id: root

    property var rootStore
    property var messageStore
    property var usersStore
    property var contactsStore
    property var messageContextMenu
    property string channelEmoji
    property bool isActiveChannel: false

    property var chatLogView
    property var emojiPopup

    // Once we redo qml we will know all section/chat related details in each message form the parent components
    // without an explicit need to fetch those details via message store/module.
    property bool isChatBlocked: false

    property int itemIndex: -1
    property string messageId: ""
    property string communityId: ""
    property string responseToMessageWithId: ""
    property string senderId: ""
    property string senderDisplayName: ""
    property string senderOptionalName: ""
    property bool senderIsEnsVerified: false
    property string senderIcon: ""
    property bool amISender: false
    property bool senderIsAdded: false
    property int senderTrustStatus: Constants.trustStatus.unknown
    readonly property string senderIconToShow: {
        if ((!senderIsAdded &&
             Global.privacyModuleInst.profilePicturesVisibility !==
             Constants.profilePicturesVisibility.everyone)) {
            return ""
        }
        return senderIcon
    }
    property string messageText: ""
    property string messageImage: ""
    property double messageTimestamp: 0 // We use double, because QML's int is too small
    property string messageOutgoingStatus: ""
    property int messageContentType: 1
    property bool pinnedMessage: false
    property string messagePinnedBy: ""
    property var reactionsModel: []
    property string linkUrls: ""
    property var transactionParams

    // External behavior changers
    property bool isInPinnedPopup: false // The pinned popup limits the number of buttons shown
    property bool disableHover: false // Used to force the HoverHandler to be active (useful for messages in popups)
    property bool placeholderMessage: false
    property bool activityCenterMessage: false
    property bool activityCenterMessageRead: true

    property int gapFrom: 0
    property int gapTo: 0

    property int prevMessageIndex: -1
    property var prevMessageAsJsonObj
    property int nextMessageIndex: -1
    property var nextMessageAsJsonObj

    property bool editModeOn: false
    property bool isEdited: false

    property string responseTo: responseToMessageWithId

    // Legacy
    property bool isCurrentUser: amISender
    property string displayUserName: senderDisplayName
    property string outgoingStatus: messageOutgoingStatus
    property string authorCurrentMsg: senderId
    property string authorPrevMsg: {
        if(!prevMessageAsJsonObj ||
                // The system message for private groups appear as created by the group host, but it shouldn't
                prevMessageAsJsonObj.contentType === Constants.messageContentType.systemMessagePrivateGroupType) {
            return ""
        }

        return prevMessageAsJsonObj.senderId
    }
    property double prevMsgTimestamp: prevMessageAsJsonObj ? prevMessageAsJsonObj.timestamp : 0
    property double nextMsgTimestamp: nextMessageAsJsonObj ? nextMessageAsJsonObj.timestamp : 0

    property bool shouldRepeatHeader: ((messageTimestamp - prevMsgTimestamp) / 60 / 1000) > Constants.repeatHeaderInterval

    property bool hasMention: false
    property bool stickersLoaded: false


    property string sticker: "Qme8vJtyrEHxABcSVGPF95PtozDgUyfr1xGjePmFdZgk9v"
    property int stickerPack: -1

    property bool isEmoji: messageContentType === Constants.messageContentType.emojiType
    property bool isImage: messageContentType === Constants.messageContentType.imageType
    property bool isAudio: messageContentType === Constants.messageContentType.audioType
    property bool isStatusMessage: messageContentType === Constants.messageContentType.systemMessagePrivateGroupType
    property bool isSticker: messageContentType === Constants.messageContentType.stickerType
    property bool isText: messageContentType === Constants.messageContentType.messageType || messageContentType === Constants.messageContentType.editType
    property bool isMessage: isEmoji || isImage || isSticker || isText || isAudio
                             || messageContentType === Constants.messageContentType.communityInviteType || messageContentType === Constants.messageContentType.transactionType

    property bool isExpired: (outgoingStatus === "sending" && (Math.floor(messageTimestamp) + 180000) < Date.now())
    property int statusAgeEpoch: 0

    signal imageClicked(var image)
    property var scrollToBottom: function () {}

    // WARNING: To much arguments here. Create an object argument.
    property var messageClickHandler: function(sender, point,
                                               isProfileClick,
                                               isSticker = false,
                                               isImage = false,
                                               image = null,
                                               isEmoji = false,
                                               hideEmojiPicker = false,
                                               isReply = false,
                                               isRightClickOnImage = false,
                                               imageSource = "") {

        if (placeholderMessage || activityCenterMessage) {
            return
        }

        messageContextMenu.myPublicKey = userProfile.pubKey
        messageContextMenu.amIChatAdmin = messageStore.amIChatAdmin()
        messageContextMenu.pinMessageAllowedForMembers = messageStore.pinMessageAllowedForMembers()
        messageContextMenu.chatType = messageStore.getChatType()

        messageContextMenu.messageId = root.messageId
        messageContextMenu.messageSenderId = root.senderId
        messageContextMenu.messageContentType = root.messageContentType
        messageContextMenu.pinnedMessage = root.pinnedMessage
        messageContextMenu.canPin = !!root.messageStore && root.messageStore.getNumberOfPinnedMessages() < Constants.maxNumberOfPins

        messageContextMenu.selectedUserPublicKey = root.senderId
        messageContextMenu.selectedUserDisplayName = root.senderDisplayName
        messageContextMenu.selectedUserIcon = root.senderIconToShow

        messageContextMenu.imageSource = imageSource

        messageContextMenu.isProfile = !!isProfileClick
        messageContextMenu.isRightClickOnImage = isRightClickOnImage
        messageContextMenu.isEmoji = isEmoji
        messageContextMenu.isSticker = isSticker
        messageContextMenu.hideEmojiPicker = hideEmojiPicker

        if (isReply){
            let obj = messageStore.getMessageByIdAsJson(responseTo)
            if(!obj)
                return

            messageContextMenu.messageSenderId = obj.senderId
            messageContextMenu.selectedUserPublicKey = obj.senderId
            messageContextMenu.selectedUserDisplayName = obj.senderDisplayName
            messageContextMenu.selectedUserIcon = obj.senderIcon
        }

        messageContextMenu.parent = sender;
        messageContextMenu.popup(point);
    }

    signal showReplyArea(string messageId, string author)


    //    function showReactionAuthors(fromAccounts, emojiId) {
    //        return root.rootStore.showReactionAuthors(fromAccounts, emojiId)
    //    }

    function startMessageFoundAnimation() {
        root.item.startMessageFoundAnimation();
    }
    /////////////////////////////////////////////


    signal openStickerPackPopup(string stickerPackId)
    // Not Refactored Yet
    //    Connections {
    //        enabled: (!placeholderMessage && !!root.rootStore)
    //        target: !!root.rootStore ? root.rootStore.allContacts : null
    //        onContactChanged: {
    //            if (pubkey === fromAuthor) {
    //                const img = appMain.getProfileImage(userPubKey, isCurrentUser, useLargeImage)
    //                if (img) {
    //                    profileImageSource = img
    //                }
    //            } else if (replyMessageIndex > -1 && pubkey === repliedMessageAuthorPubkey) {
    //                const imgReply = appMain.getProfileImage(repliedMessageAuthorPubkey, repliedMessageAuthorIsCurrentUser, false)
    //                if (imgReply) {
    //                    repliedMessageUserImage = imgReply
    //                }
    //            }
    //        }
    //    }

    z: (typeof chatLogView === "undefined") ? 1 : (chatLogView.count - index)

    sourceComponent: {
        switch(messageContentType) {
        case Constants.messageContentType.chatIdentifier:
            return channelIdentifierComponent
        case Constants.messageContentType.fetchMoreMessagesButton:
            return fetchMoreMessagesButtonComponent
        case Constants.messageContentType.systemMessagePrivateGroupType:
            return privateGroupHeaderComponent
        case Constants.messageContentType.gapType:
            return gapComponent
        default:
            return messageComponent
        }
    }

    QtObject {
        id: d

        readonly property int chatButtonSize: 32

        property string activeMessage
        readonly property bool isMessageActive: typeof activeMessage !== "undefined" && activeMessage === messageId

        function setMessageActive(messageId, active) {

            // TODO: Is argument messageId actually needed?
            //       It was probably used with dynamic scoping,
            //       but not this method can be moved to private `d`.
            //       Probably that it was done this way, because `MessageView` is reused as delegate.

            if (active) {
                d.activeMessage = messageId;
                return;
            }
            if (d.activeMessage === messageId) {
                d.activeMessage = "";
                return;
            }
        }
    }

    Connections {
        enabled: d.isMessageActive
        target: root.messageContextMenu
        onClosed: {
            d.setMessageActive(root.messageId, false)
        }
    }

    Component {
        id: gapComponent
        GapComponent {
            gapFrom: root.gapFrom
            gapTo: root.gapTo
            onClicked: {
                messageStore.fillGaps(messageId)
                root.visible = false;
                root.height = 0;
            }
        }
    }

    Component {
        id: fetchMoreMessagesButtonComponent
        FetchMoreMessagesButton {
            nextMessageIndex: root.nextMessageIndex
            nextMsgTimestamp: root.nextMsgTimestamp
            onTimerTriggered: {
                messageStore.requestMoreMessages();
            }
        }
    }

    Component {
        id: channelIdentifierComponent
        ChannelIdentifierView {
            chatName: root.senderDisplayName
            chatId: root.messageStore.getChatId()
            chatType: root.messageStore.getChatType()
            chatColor: root.messageStore.getChatColor()
            chatEmoji: root.channelEmoji
            amIChatAdmin: root.messageStore.amIChatAdmin()
            chatIcon: {
                if ((root.messageStore.getChatType() === Constants.chatType.privateGroupChat) &&
                     root.messageStore.getChatIcon() !== "") {
                    return root.messageStore.getChatIcon()
                }
                return root.senderIconToShow
            }
        }
    }

    // Private group Messages
    Component {
        id: privateGroupHeaderComponent
        StyledText {
            wrapMode: Text.Wrap
            text: {
                return `<html>`+
                        `<head>`+
                        `<style type="text/css">`+
                        `a {`+
                        `color: ${Style.current.textColor};`+
                        `text-decoration: none;`+
                        `}`+
                        `</style>`+
                        `</head>`+
                        `<body>`+
                        `${messageText}`+
                        `</body>`+
                        `</html>`;
            }
            visible: isStatusMessage
            font.pixelSize: 14
            color: Style.current.secondaryText
            width:  parent.width - 120
            horizontalAlignment: Text.AlignHCenter
            anchors.horizontalCenter: parent.horizontalCenter
            textFormat: Text.RichText
            topPadding: root.prevMessageIndex === 1 ? Style.current.bigPadding : 0
        }
    }

    Component {
        id: messageComponent

        StatusMessage {
            id: delegate

            function convertContentType(value) {
                switch (value) {
                case Constants.messageContentType.messageType:
                    return StatusMessage.ContentType.Text;
                case Constants.messageContentType.stickerType:
                    return StatusMessage.ContentType.Sticker;
                case Constants.messageContentType.emojiType:
                    return StatusMessage.ContentType.Emoji;
                case Constants.messageContentType.transactionType:
                    return StatusMessage.ContentType.Transaction;
                case Constants.messageContentType.imageType:
                    return StatusMessage.ContentType.Image;
                case Constants.messageContentType.audioType:
                    return StatusMessage.ContentType.Audio;
                case Constants.messageContentType.communityInviteType:
                    return StatusMessage.ContentType.Invitation;
                case Constants.messageContentType.fetchMoreMessagesButton:
                case Constants.messageContentType.chatIdentifier:
                case Constants.messageContentType.unknownContentType:
                case Constants.messageContentType.statusType:
                case Constants.messageContentType.systemMessagePrivateGroupType:
                case Constants.messageContentType.gapType:
                case Constants.messageContentType.editType:
                default:
                    return StatusMessage.ContentType.Unknown;
                }
            }

            readonly property int contentType: convertContentType(root.messageContentType)
            readonly property bool isReply: root.responseTo !== ""
            readonly property var replyMessage: root.messageStore && isReply ? root.messageStore.getMessageByIdAsJson(root.responseTo) : null
            readonly property string replySenderId: replyMessage ? replyMessage.senderId : ""

            function editCompletedHandler(newMessageText) {
                const message = root.rootStore.plainText(StatusQUtils.Emoji.deparse(newMessageText))
                if (message.length <= 0)
                    return;

                const interpretedMessage = root.messageStore.interpretMessage(message)
                root.messageStore.setEditModeOff(root.messageId)
                root.messageStore.editMessage(root.messageId, interpretedMessage)
            }

            audioMessageInfoText: qsTr("Audio Message")
            cancelButtonText: qsTr("Cancel")
            saveButtonText: qsTr("Save")
            loadingImageText: qsTr("Loading image...")
            errorLoadingImageText: qsTr("Error loading the image")
            resendText: qsTr("Resend")
            pinnedMsgInfoText: qsTr("Pinned by")
            reactionIcons: [
                Style.svg("emojiReactions/heart"),
                Style.svg("emojiReactions/thumbsUp"),
                Style.svg("emojiReactions/thumbsDown"),
                Style.svg("emojiReactions/laughing"),
                Style.svg("emojiReactions/sad"),
                Style.svg("emojiReactions/angry"),
            ]

            timestamp: root.messageTimestamp
            editMode: root.editModeOn
            isAReply: delegate.isReply
            isEdited: root.isEdited
            hasMention: root.hasMention
            isPinned: root.pinnedMessage
            pinnedBy: root.pinnedMessage ? Utils.getContactDetailsAsJson(root.messagePinnedBy).displayName : ""
            hasExpired: root.isExpired
            reactionsModel: root.reactionsModel

            previousMessageIndex: root.prevMessageIndex
            previousMessageTimestamp: root.prevMsgTimestamp

            showHeader: root.authorCurrentMsg !== root.authorPrevMsg ||
                        root.shouldRepeatHeader || dateGroupVisible || isAReply
            isActiveMessage: d.isMessageActive

            disableHover: root.disableHover ||
                          (root.chatLogView && root.chatLogView.flickingVertically) ||
                          activityCenterMessage ||
                          root.messageContextMenu.opened ||
                          !!Global.profilePopupOpened ||
                          !!Global.popupOpened

            hideQuickActions: root.isChatBlocked ||
                              root.placeholderMessage ||
                              root.activityCenterMessage ||
                              root.isInPinnedPopup

            overrideBackground: root.activityCenterMessage || root.placeholderMessage
            overrideBackgroundColor: {
                if (root.activityCenterMessage && root.activityCenterMessageRead)
                    return Utils.setColorAlpha(Style.current.blue, 0.1);
                return "transparent";
            }


            timestampString: Utils.formatShortTime(timestamp,
                                                   localAccountSensitiveSettings.is24hTimeFormat)

            timestampTooltipString: Utils.formatLongDateTime(timestamp,
                                                             localAccountSensitiveSettings.isDDMMYYDateFormat,
                                                             localAccountSensitiveSettings.is24hTimeFormat);

            onEditCancelled: {
                root.messageStore.setEditModeOff(root.messageId)
            }

            onEditCompleted: {
                delegate.editCompletedHandler(newMsgText)
            }

            onImageClicked: {
                switch (mouse.button) {
                case Qt.LeftButton:
                    root.imageClicked(image, mouse);
                    break;
                case Qt.RightButton:
                    root.messageClickHandler(image, Qt.point(mouse.x, mouse.y), false, false, true, image, false, true, false, true, imageSource)
                    break;
                }
            }

            onLinkActivated: {
                if (link.startsWith('//')) {
                    const pubkey = link.replace("//", "");
                    Global.openProfilePopup(pubkey)
                    return;
                }

                Global.openLink(link)
            }

            onProfilePictureClicked: {
                d.setMessageActive(root.messageId, true);
                root.messageClickHandler(sender, Qt.point(mouse.x, mouse.y), true);
            }

            onReplyProfileClicked: {
                d.setMessageActive(root.messageId, true);
                root.messageClickHandler(sender, Qt.point(mouse.x, mouse.y), true, false, false, null, false, false, true);
            }

            onSenderNameClicked: {
                d.setMessageActive(root.messageId, true);
                root.messageClickHandler(sender, Qt.point(mouse.x, mouse.y), true);
            }

            onToggleReactionClicked: {
                if (root.isChatBlocked)
                    return

                if (!root.messageStore) {
                    console.error("Reaction can not be toggled, message store is not valid")
                    return
                }

                root.messageStore.toggleReaction(root.messageId, emojiId)
            }

            onAddReactionClicked: {
                if (root.isChatBlocked)
                    return;

                d.setMessageActive(root.messageId, true);
                root.messageClickHandler(sender, Qt.point(mouse.x, mouse.y), false, false, false, null, true, false);
            }

            onStickerClicked: {
                root.openStickerPackPopup(root.stickerPack);
            }

            mouseArea {
                acceptedButtons: root.activityCenterMessage ? Qt.LeftButton : Qt.RightButton
                enabled: !root.isChatBlocked &&
                         !root.placeholderMessage &&
                         delegate.contentType !== StatusMessage.ContentType.Image
                onClicked: {
                    d.setMessageActive(root.messageId, true);
                    root.messageClickHandler(this, Qt.point(mouse.x, mouse.y),
                                             false, false, false, null, root.isEmoji, false, false, false, "");
                }
            }

            messageDetails: StatusMessageDetails {
                contentType: delegate.contentType
                messageText: root.messageText
                messageContent: {
                    switch (delegate.contentType)
                    {
                    case StatusMessage.ContentType.Sticker:
                        return root.sticker;
                    case StatusMessage.ContentType.Image:
                        return root.messageImage;
                    }
                    return "";
                }

                amISender: root.amISender
                sender.id: root.senderId
                sender.displayName: root.senderDisplayName
                sender.secondaryName: root.senderOptionalName
                sender.isEnsVerified: root.senderIsEnsVerified
                sender.isContact: root.senderIsAdded
                sender.trustIndicator: root.senderTrustStatus
                sender.profileImage {
                    width: 40
                    height: 40
                    name: root.senderIcon || ""
                    pubkey: root.senderId
                    colorId: Utils.colorIdForPubkey(root.senderId)
                    colorHash: Utils.getColorHashAsJson(root.senderId)
                }
            }

            replyDetails: StatusMessageDetails {
                messageText:  delegate.replyMessage ? delegate.replyMessage.messageText : ""
                contentType: delegate.replyMessage ? delegate.convertContentType(delegate.replyMessage.contentType) : 0
                messageContent: {
                    if (!delegate.replyMessage)
                        return "";
                    switch (contentType) {
                    case StatusMessage.ContentType.Sticker:
                        return delegate.replyMessage.sticker;
                    case StatusMessage.ContentType.Image:
                        return delegate.replyMessage.messageImage;
                    }
                    return "";
                }

                amISender: delegate.replyMessage && delegate.replyMessage.amISender
                sender.id: delegate.replyMessage ? delegate.replyMessage.senderId : ""
                sender.isContact: delegate.replyMessage && delegate.replyMessage.senderIsAdded
                sender.displayName:  delegate.replyMessage ? delegate.replyMessage.senderDisplayName: ""
                sender.isEnsVerified: delegate.replyMessage && delegate.replyMessage.senderEnsVerified
                sender.secondaryName: delegate.replyMessage ? delegate.replyMessage.senderOptionalName : ""
                sender.profileImage {
                    width: 20
                    height: 20
                    name:  delegate.replyMessage ? delegate.replyMessage.senderIcon : ""
                    pubkey: delegate.replySenderId
                    colorId: Utils.colorIdForPubkey(delegate.replySenderId)
                    colorHash: Utils.getColorHashAsJson(delegate.replySenderId)
                }
            }

            statusChatInput: StatusChatInput {
                id: editTextInput
                objectName: "editMessageInput"

                readonly property string messageText: editTextInput.textInput.text

                // TODO: Move this property and Escape handler to StatusChatInput
                property bool suggestionsOpened: false

                width: parent.width

                Keys.onEscapePressed: {
                    if (!suggestionsOpened) {
                        delegate.editCancelled()
                    }
                    suggestionsOpened = false
                }

                store: root.rootStore
                usersStore: root.usersStore
                emojiPopup: root.emojiPopup
                messageContextMenu: root.messageContextMenu

                chatType: root.messageStore.getChatType()
                isEdit: true

                onSendMessage: {
                    delegate.editCompletedHandler(editTextInput.textInput.text)
                }

                suggestions.onVisibleChanged: {
                    if (suggestions.visible) {
                        suggestionsOpened = true
                    }
                }

                Component.onCompleted: {
                    parseMessage(root.messageText);
                }
            }

            linksComponent: Component {
                LinksMessageView {
                    linkUrls: root.linkUrls
                    container: root
                    messageStore: root.messageStore
                    store: root.rootStore
                    isCurrentUser: root.amISender
                    onImageClicked: {
                        root.imageClicked(image);
                    }
                }
            }

            transcationComponent: Component {
                TransactionBubbleView {
                    transactionParams: root.transactionParams
                    store: root.rootStore
                    contactsStore: root.contactsStore
                }
            }

            invitationComponent: Component {
                InvitationBubbleView {
                    store: root.rootStore
                    communityId: root.communityId
                }
            }

            quickActions: [
                Loader {
                    active: !root.isInPinnedPopup
                    sourceComponent: StatusFlatRoundButton {
                        width: d.chatButtonSize
                        height: d.chatButtonSize
                        icon.name: "reaction-b"
                        type: StatusFlatRoundButton.Type.Tertiary
                        tooltip.text: qsTr("Add reaction")
                        onClicked: {
                            d.setMessageActive(root.messageId, true)
                            root.messageClickHandler(this, Qt.point(mouse.x, mouse.y), false, false, false, null, true, false)
                        }
                    }
                },
                Loader {
                    active: !root.isInPinnedPopup
                    sourceComponent: StatusFlatRoundButton {
                        objectName: "replyToMessageButton"
                        width: d.chatButtonSize
                        height: d.chatButtonSize
                        icon.name: "reply"
                        type: StatusFlatRoundButton.Type.Tertiary
                        tooltip.text: qsTr("Reply")
                        onClicked: {
                            root.showReplyArea(root.messageId, root.senderId)
                            if (messageContextMenu.closeParentPopup) {
                                messageContextMenu.closeParentPopup()
                            }
                        }
                    }
                },
                Loader {
                    active: !root.isInPinnedPopup && root.isText && !root.editModeOn && root.amISender
                    visible: active
                    sourceComponent: StatusFlatRoundButton {
                        objectName: "editMessageButton"
                        width: d.chatButtonSize
                        height: d.chatButtonSize
                        icon.name: "edit_pencil"
                        type: StatusFlatRoundButton.Type.Tertiary
                        tooltip.text: qsTr("Edit")
                        onClicked: {
                            root.messageStore.setEditModeOn(root.messageId)
                        }
                    }
                },
                Loader {
                    active: {
                        if (!root.messageStore)
                            return false

                        const chatType = root.messageStore.getChatType();
                        const amIChatAdmin = root.messageStore.amIChatAdmin();
                        const pinMessageAllowedForMembers = root.messageStore.pinMessageAllowedForMembers()

                        return chatType === Constants.chatType.oneToOne ||
                                chatType === Constants.chatType.privateGroupChat && amIChatAdmin ||
                                chatType === Constants.chatType.communityChat && (amIChatAdmin || pinMessageAllowedForMembers);

                    }
                    sourceComponent: StatusFlatRoundButton {
                        objectName: "MessageView_toggleMessagePin"
                        width: d.chatButtonSize
                        height: d.chatButtonSize
                        icon.name: root.pinnedMessage ? "unpin" : "pin"
                        type: StatusFlatRoundButton.Type.Tertiary
                        tooltip.text: root.pinnedMessage ? qsTr("Unpin") : qsTr("Pin")
                        onClicked: {
                            if (root.pinnedMessage) {
                                messageStore.unpinMessage(root.messageId)
                                return;
                            }

                            if (!!root.messageStore && root.messageStore.getNumberOfPinnedMessages() < Constants.maxNumberOfPins) {
                                messageStore.pinMessage(root.messageId)
                                return;
                            }

                            if (!chatContentModule) {
                                console.warn("error on open pinned messages limit reached from message context menu - chat content module is not set")
                                return;
                            }

                            Global.openPopup(Global.pinnedMessagesPopup, {
                                                 store: root.rootStore,
                                                 messageStore: messageStore,
                                                 messagesModule: chatContentModule.messagesModule,
                                                 pinnedMessagesModel: chatContentModule.pinnedMessagesModel,
                                                 messageToPin: root.messageId
                                             });
                        }
                    }
                },
                Loader {
                    active: {
                        if (root.isInPinnedPopup)
                            return false;
                        if (!root.messageStore)
                            return false;
                        const isMyMessage = senderId !== "" && senderId === userProfile.pubKey;
                        const chatType = root.messageStore.getChatType();
                        return isMyMessage &&
                                (messageContentType === Constants.messageContentType.messageType ||
                                 messageContentType === Constants.messageContentType.stickerType ||
                                 messageContentType === Constants.messageContentType.emojiType ||
                                 messageContentType === Constants.messageContentType.imageType ||
                                 messageContentType === Constants.messageContentType.audioType);
                    }
                    sourceComponent: StatusFlatRoundButton {
                        objectName: "chatDeleteMessageButton"
                        width: d.chatButtonSize
                        height: d.chatButtonSize
                        icon.name: "delete"
                        type: StatusFlatRoundButton.Type.Tertiary
                        tooltip.text: qsTr("Delete")
                        onClicked: {
                            if (!localAccountSensitiveSettings.showDeleteMessageWarning) {
                                messageStore.deleteMessage(root.messageId)
                            }
                            else {
                                Global.openPopup(deleteMessageConfirmationDialogComponent)
                            }
                        }
                    }
                }
            ]
        }
    }

    Component {
        id: deleteMessageConfirmationDialogComponent

        ConfirmationDialog {
            confirmButtonObjectName: "chatButtonsPanelConfirmDeleteMessageButton"
            header.title: qsTrId("Confirm deleting this message")
            confirmationText: qsTrId("Are you sure you want to delete this message? Be aware that other clients are not guaranteed to delete the message as well.")
            height: 260
            checkbox.visible: true
            executeConfirm: function () {
                if (checkbox.checked) {
                    localAccountSensitiveSettings.showDeleteMessageWarning = false
                }

                close()
                messageStore.deleteMessage(root.messageId)
            }
            onClosed: {
                destroy()
            }
        }
    }
}

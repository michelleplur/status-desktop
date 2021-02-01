import QtQuick 2.13
import "../../../../shared"
import "../../../../imports"
import "./MessageComponents"
import "../components"

Item {
    property string fromAuthor: "0x0011223344556677889910"
    property string userName: "Jotaro Kujo"
    property string alias: ""
    property string localName: ""
    property string message: "That's right. We're friends...  Of justice, that is."
    property string plainText: "That's right. We're friends...  Of justice, that is."
    property string identicon: "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAZAAAAGQAQMAAAC6caSPAAAABlBMVEXMzMz////TjRV2AAAAAWJLR0QB/wIt3gAAACpJREFUGBntwYEAAAAAw6D7Uw/gCtUAAAAAAAAAAAAAAAAAAAAAAAAAgBNPsAABAjKCqQAAAABJRU5ErkJggg=="
    property bool isCurrentUser: false
    property string timestamp: "1234567"
    property string sticker: "Qme8vJtyrEHxABcSVGPF95PtozDgUyfr1xGjePmFdZgk9v"
    property int contentType: 2 // constants don't work in default props
    property string chatId: "chatId"
    property string outgoingStatus: ""
    property string responseTo: ""
    property string messageId: ""
    property string emojiReactions: ""
    property int prevMessageIndex: -1
    property bool timeout: false
    property string linkUrls: ""
    property bool placeholderMessage: false
    property string communityId: ""

    property string authorCurrentMsg: "authorCurrentMsg"
    property string authorPrevMsg: "authorPrevMsg"

    property bool isEmoji: contentType === Constants.emojiType
    property bool isImage: contentType === Constants.imageType
    property bool isAudio: contentType === Constants.audioType
    property bool isStatusMessage: contentType === Constants.systemMessagePrivateGroupType
    property bool isSticker: contentType === Constants.stickerType
    property bool isText: contentType === Constants.messageType
    property bool isMessage: isEmoji || isImage || isSticker || isText || isAudio || contentType === Constants.communityInviteType

    property bool isExpired: (outgoingStatus == "sending" && (Math.floor(timestamp) + 180000) < Date.now())
    property bool isStatusUpdate: false

    property int replyMessageIndex: chatsModel.messageList.getMessageIndex(responseTo);
    property string repliedMessageAuthor: replyMessageIndex > -1 ? chatsModel.messageList.getMessageData(replyMessageIndex, "userName") : "";
    property string repliedMessageContent: replyMessageIndex > -1 ? chatsModel.messageList.getMessageData(replyMessageIndex, "message") : "";
    property int repliedMessageType: replyMessageIndex > -1 ? parseInt(chatsModel.messageList.getMessageData(replyMessageIndex, "contentType")) : 0;
    property string repliedMessageImage: replyMessageIndex > -1 ? chatsModel.messageList.getMessageData(replyMessageIndex, "image") : "";

    property var imageClick: function () {}
    property var scrollToBottom: function () {}
    property string userPubKey: {
        if (contentType === Constants.chatIdentifier) {
            return chatId
        }
        return fromAuthor
    }
    property bool useLargeImage: contentType === Constants.chatIdentifier

    property string profileImageSource: !placeholderMessage && appMain.getProfileImage(userPubKey, isCurrentUser, useLargeImage) || ""

    Connections {
        enabled: !placeholderMessage
        target: profileModel.contacts.list
        onContactChanged: {
            if (pubkey === fromAuthor) {
                profileImageSource = appMain.getProfileImage(userPubKey, isCurrentUser, useLargeImage)
            }
        }
    }

    id: root
    width: parent.width
    anchors.right: !isCurrentUser ? undefined : parent.right
    height: {
        switch(contentType) {
            case Constants.chatIdentifier:
                return childrenRect.height + 50
            default: return childrenRect.height
        }
    }

    function clickMessage(isProfileClick, isSticker = false, isImage = false, image = null, emojiOnly = false) {
        if (isImage) {
            imageClick(image);
            return;
        }

        if (!isProfileClick) {
            SelectedMessage.set(messageId, fromAuthor);
        }
        // Get contact nickname
        let nickname = appMain.getUserNickname(fromAuthor)
        messageContextMenu.isProfile = !!isProfileClick
        messageContextMenu.isSticker = isSticker
        messageContextMenu.emojiOnly = emojiOnly
        messageContextMenu.show(userName, fromAuthor, root.profileImageSource || identicon, "", nickname)
        // Position the center of the menu where the mouse is
        messageContextMenu.x = messageContextMenu.x - messageContextMenu.width / 2
    }

    Loader {
        active: true
        width: parent.width
        sourceComponent: {
            switch(contentType) {
                case Constants.chatIdentifier:
                    return channelIdentifierComponent
                case Constants.fetchMoreMessagesButton:
                    return fetchMoreMessagesButtonComponent
                case Constants.systemMessagePrivateGroupType:
                    return privateGroupHeaderComponent
                case Constants.transactionType:
                    return transactionBubble
                case Constants.communityInviteType:
                    return invitationBubble
                default:
                    return isStatusUpdate ? statusUpdateComponent :
                                            (appSettings.compactMode ? compactMessageComponent : messageComponent)

            }
        }
    }

    Timer {
        id: timer
    }

    Component {
        id: fetchMoreMessagesButtonComponent
        Item {
            visible: chatsModel.activeChannel.chatType !== Constants.chatTypePrivateGroupChat || chatsModel.activeChannel.isMember
            id: wrapper
            height: wrapper.visible ? childrenRect.height + Style.current.smallPadding*2 : 0
            anchors.left: parent.left
            anchors.right: parent.right
            Separator {
                id: sep1
            }
            StyledText {
                id: fetchMoreButton
                font.weight: Font.Medium
                font.pixelSize: Style.current.primaryTextFontSize
                color: Style.current.blue
                //% "↓ Fetch more messages"
                text: qsTrId("load-more-messages")
                horizontalAlignment: Text.AlignHCenter
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: sep1.bottom
                anchors.topMargin: Style.current.smallPadding
                MouseArea {
                  cursorShape: Qt.PointingHandCursor
                  anchors.fill: parent
                  onClicked: {
                    chatsModel.requestMoreMessages(Constants.fetchRangeLast24Hours);                    
                    timer.setTimeout(function(){ 
                        chatsModel.hideLoadingIndicator()
                    }, 3000);
                  }
                }
            }
            StyledText {
                id: fetchDate
                anchors.top: fetchMoreButton.bottom
                anchors.topMargin: 3
                anchors.horizontalCenter: parent.horizontalCenter
                horizontalAlignment: Text.AlignHCenter
                color: Style.current.darkGrey
                //% "before %1"
                text: qsTrId("before--1").arg(new Date(chatsModel.oldestMsgTimestamp*1000).toDateString())
            }
            Separator {
                anchors.top: fetchDate.bottom
                anchors.topMargin: Style.current.smallPadding
            }
        }
    }

    Component {
        id: channelIdentifierComponent
        ChannelIdentifier {
            authorCurrentMsg: root.authorCurrentMsg
            profileImage: profileImageSource
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
                    `${message}`+
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
        NormalMessage {
            clickMessage: root.clickMessage
            linkUrls: root.linkUrls
            isCurrentUser: root.isCurrentUser
            contentType: root.contentType
            container: root
        }
    }

    Component {
        id: statusUpdateComponent
        StatusUpdate {
            clickMessage: root.clickMessage
            container: root
        }
    }

    Component {
        id: compactMessageComponent
        CompactMessage {
            clickMessage: root.clickMessage
            linkUrls: root.linkUrls
            isCurrentUser: root.isCurrentUser
            contentType: root.contentType
            container: root
        }
    }

    Component {
        id: transactionBubble
        TransactionBubble {}
    }

    Component {
        id: invitationBubble
        InvitationBubble {}
    }
}

/*##^##
Designer {
    D{i:0;formeditorColor:"#ffffff";formeditorZoom:1.75;height:80;width:800}
}
##^##*/

import QtQuick 2.14
import QtQuick.Layouts 1.4

import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Popups 0.1

import utils 1.0
import shared.panels 1.0

import "../../views"
import "../../panels/communities"

StatusStackModal {
    id: root

    property var rootStore
    property var contactsStore
    property var community
    property var communitySectionModule

    property var pubKeys: ([])
    property string inviteMessage: ""
    property string validationError: ""
    property string successMessage: ""

    signal sendInvites(var pubKeys, string inviteMessage)

    function processInviteResult(error) {
        if (error) {
            console.error('Error inviting', error);
            root.validationError = error;
        } else {
            root.validationError = "";
            root.successMessage = qsTr("Invite successfully sent");
        }
    }

    onOpened: {
        root.pubKeys = [];
        root.successMessage = "";
        root.validationError = "";
    }

    stackTitle: qsTr("Invite Contacts to %1").arg(community.name)
    width: 640
    height: 700
    leftPadding: 0
    rightPadding: 0

    nextButton: StatusButton {
        text: qsTr("Next")
        enabled: root.pubKeys.length
        onClicked: {
            root.currentIndex++;
        }
    }

    finishButton: StatusButton {
        enabled: root.pubKeys.length > 0
        text: qsTr("Send Invites")
        onClicked: {
            root.sendInvites(root.pubKeys, root.inviteMessage);
            root.close();
        }
    }

    subHeaderItem: StyledText {
        text: root.validationError || root.successMessage
        visible: root.validationError !== "" || root.successMessage !== ""
        font.pixelSize: 13
        color: !!root.validationError ? Style.current.danger : Style.current.success
        horizontalAlignment: Text.AlignHCenter
        height: visible ? contentHeight : 0
    }

    stackItems: [
        CommunityProfilePopupInviteFriendsPanel {
            width: parent.width
            rootStore: root.rootStore
            contactsStore: root.contactsStore
            community: root.community
            onPubKeysChanged: root.pubKeys = pubKeys
        },
        CommunityProfilePopupInviteMessagePanel {
            width: parent.width
            contactsStore: root.contactsStore
            pubKeys: root.pubKeys
            onInviteMessageChanged: root.inviteMessage = inviteMessage
        }
    ]
}


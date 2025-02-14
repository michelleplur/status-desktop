import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13

import StatusQ.Core 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import StatusQ.Core.Theme 0.1

import utils 1.0

import shared.views 1.0
import shared.panels 1.0
import shared.popups 1.0
import shared.controls 1.0
import shared.views.chat 1.0

import "../stores"
import "../panels"
import "../popups"

SettingsContentBase {
    id: root
    onWidthChanged: { contentItem.width = contentWidth; }
    onHeightChanged: { contentItem.height = height; }
    property ContactsStore contactsStore

    property alias searchStr: searchBox.text
    property bool isPending: false

    headerComponents: [
        StatusButton {
            implicitHeight: 38
            size: StatusBaseButton.Size.Normal
            text: qsTr("Send contact request to chat key")
            onClicked: {
                sendContactRequest.open()
            }
        }
    ]


    function openContextMenu(publicKey, name, icon) {
        contactContextMenu.selectedUserPublicKey = publicKey
        contactContextMenu.selectedUserDisplayName = name
        contactContextMenu.selectedUserIcon = icon
        contactContextMenu.popup()
    }

    Item {
        id: contentItem

        MessageContextMenuView {
            id: contactContextMenu
            store: ({contactsStore: root.contactsStore})
            isProfile: true

            onOpenProfileClicked: function (pubkey, state) {
                Global.openProfilePopup(pubkey, null, state)
            }

            onCreateOneToOneChat: function (communityId, chatId, ensName) {
                root.contactsStore.joinPrivateChat(chatId)
            }
        }

        SearchBox {
            id: searchBox
            anchors.left: parent.left
            anchors.leftMargin: Style.current.padding
            anchors.right: parent.right
            placeholderText: qsTr("Search by a display name or chat key")
        }

        StatusTabBar {
            id: contactsTabBar
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: searchBox.bottom
            anchors.topMargin: Style.current.padding

            StatusTabButton {
                id: contactsBtn
                leftPadding: Style.current.padding
                width: implicitWidth
                text: qsTr("Contacts")
            }
            StatusTabButton {
                id: pendingRequestsBtn
                width: implicitWidth
                enabled: root.contactsStore.receivedContactRequestsModel.count > 0 ||
                         root.contactsStore.sentContactRequestsModel.count > 0
                text: qsTr("Pending Requests")
                badge.value: root.contactsStore.receivedContactRequestsModel.count
            }
            // Temporary commented until we provide appropriate flags on the `status-go` side to cover all sections.
            //            StatusTabButton {
            //                id: rejectedRequestsBtn
            //                width: implicitWidth
            //                enabled: root.contactsStore.receivedButRejectedContactRequestsModel.count > 0 ||
            //                         root.contactsStore.sentButRejectedContactRequestsModel.count > 0
            //                btnText: qsTr("Rejected Requests")
            //            }
            StatusTabButton {
                id: blockedBtn
                width: implicitWidth
                enabled: root.contactsStore.blockedContactsModel.count > 0
                text: qsTr("Blocked")
            }
        }

        StackLayout {
            id: stackLayout
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: contactsTabBar.bottom
            anchors.topMargin: Style.current.smallPadding
            anchors.bottom: parent.bottom
            currentIndex: contactsTabBar.currentIndex
            // CONTACTS
            Column {
                spacing: Style.current.padding
                ContactsListPanel {
                    id: verifiedContacts
                    width: parent.width
                    height: ((contactsListHeight < (stackLayout.height/2)) ? contactsListHeight :
                            (stackLayout.height-mutualContacts.contactsListHeight))
                    scrollbarOn: mutualContacts.contactsListHeight > (stackLayout.height/2) ?
                                 (contactsListHeight > (stackLayout.height/2)) : (contactsListHeight > parent.height)
                    title: qsTr("Identity Verified Contacts")
                    contactsModel: root.contactsStore.myContactsModel
                    searchString: searchBox.text
                    onOpenContactContextMenu: function (publicKey, name, icon) {
                        root.openContextMenu(publicKey, name, icon)
                    }
                    contactsStore: root.contactsStore
                    panelUsage: Constants.contactsPanelUsage.verifiedMutualContacts
                    onSendMessageActionTriggered: {
                        root.contactsStore.joinPrivateChat(publicKey)
                    }
                }

                ContactsListPanel {
                    id: mutualContacts
                    width: parent.width
                    height: (contactsListHeight+50)
                    scrollbarOn: verifiedContacts.contactsListHeight > (stackLayout.height/2) ?
                                 (contactsListHeight > (stackLayout.height/2)) : (contactsListHeight > parent.height)
                    title: qsTr("Contacts")
                    contactsModel: root.contactsStore.myContactsModel
                    searchString: searchBox.text
                    contactsStore: root.contactsStore
                    onOpenContactContextMenu: function (publicKey, name, icon) {
                        root.openContextMenu(publicKey, name, icon)
                    }
                    panelUsage: Constants.contactsPanelUsage.mutualContacts

                    onSendMessageActionTriggered: {
                        root.contactsStore.joinPrivateChat(publicKey)
                    }
                }
                Item {
                    width: parent.width
                    height: parent.height
                    NoFriendsRectangle {
                        anchors.centerIn: parent
                        visible: root.contactsStore.myContactsModel.count === 0
                        text: qsTr("You don’t have any contacts yet")
                    }
                }
            }

            // PENDING REQUESTS
            Column {
                ContactsListPanel {
                    id: receivedRequests
                    width: parent.width
                    height: ((contactsListHeight < (stackLayout.height/2)) ? contactsListHeight :
                            (stackLayout.height-sentRequests.contactsListHeight))
                    scrollbarOn: (sentRequests.contactsListHeight > (stackLayout.height/2)) ?
                                 (contactsListHeight > (stackLayout.height/2)) :
                                 (contactsListHeight > (stackLayout.height - sentRequests.contactsListHeight))
                    title: qsTr("Received")
                    searchString: searchBox.text
                    contactsStore: root.contactsStore
                    onOpenContactContextMenu: function (publicKey, name, icon) {
                        root.openContextMenu(publicKey, name, icon)
                    }
                    contactsModel: root.contactsStore.receivedContactRequestsModel
                    panelUsage: Constants.contactsPanelUsage.receivedContactRequest

                    onContactRequestAccepted: {
                        root.contactsStore.acceptContactRequest(publicKey)
                    }

                    onContactRequestRejected: {
                        root.contactsStore.dismissContactRequest(publicKey)
                    }

                    onShowVerificationRequest: {
                        try {
                            let request = root.contactsStore.getVerificationDetailsFromAsJson(publicKey)
                            Global.openPopup(contactVerificationRequestPopupComponent, {
                                senderPublicKey: request.from,
                                senderDisplayName: request.displayName,
                                senderIcon: request.icon,
                                challengeText: request.challenge,
                                responseText: request.response,
                                messageTimestamp: request.requestedAt,
                                responseTimestamp: request.repliedAt
                            })
                        } catch (e) {
                            console.error("Error getting or parsing verification data", e)
                        }
                    }
                }

                ContactsListPanel {
                    id: sentRequests
                    width: parent.width
                    height: (contactsListHeight+50)
                    scrollbarOn: (receivedRequests.contactsListHeight > (stackLayout.height/2)) ?
                                 (contactsListHeight > (stackLayout.height/2)) :
                                 (contactsListHeight > (stackLayout.height - receivedRequests.contactsListHeight))
                    title: qsTr("Sent")
                    searchString: searchBox.text
                    contactsStore: root.contactsStore
                    onOpenContactContextMenu: function (publicKey, name, icon) {
                        root.openContextMenu(publicKey, name, icon)
                    }
                    contactsModel: root.contactsStore.sentContactRequestsModel
                    panelUsage: Constants.contactsPanelUsage.sentContactRequest
                }
            }

            // Temporary commented until we provide appropriate flags on the `status-go` side to cover all sections.
            //            // REJECTED REQUESTS
            //            Item {
            //                Layout.fillWidth: true
            //                //Layout.fillHeight: true

            //                ColumnLayout {
            //                    //anchors.fill: parent

            //                    ContactsListPanel {
            //                        Layout.fillWidth: true
            //                        Layout.preferredHeight: root.height * 0.5
            //                        clip: true
            //                        title: qsTr("Received")
            //                        searchString: searchBox.text
            //                        contactsStore: root.contactsStore
            //                        onOpenContactContextMenu: function (publicKey, name, icon) {
            //                           root.openContextMenu(publicKey, name, icon)
            //                        }
            //                        contactsModel: root.contactsStore.receivedButRejectedContactRequestsModel
            //                        panelUsage: Constants.contactsPanelUsage.rejectedReceivedContactRequest

            //                        onRejectionRemoved: {
            //                            root.contactsStore.removeContactRequestRejection(publicKey)
            //                        }
            //                    }

            //                    ContactsListPanel {
            //                        Layout.fillWidth: true
            //                        Layout.preferredHeight: root.height * 0.5
            //                        clip: true
            //                        title: qsTr("Sent")
            //                        searchString: searchBox.text
            //                        contactsStore: root.contactsStore
            //                        onOpenContactContextMenu: function (publicKey, name, icon) {
            //                             root.openContextMenu(publicKey, name, icon)
            //                         }
            //                        contactsModel: root.contactsStore.sentButRejectedContactRequestsModel
            //                        panelUsage: Constants.contactsPanelUsage.rejectedSentContactRequest
            //                    }

            //                    Item {
            //                        Layout.fillWidth: true
            //                        Layout.fillHeight: true
            //                    }
            //                }
            //            }

            // BLOCKED
            ContactsListPanel {
                width: parent.width
                height: (contactsListHeight+50)
                searchString: searchBox.text
                contactsStore: root.contactsStore
                onOpenContactContextMenu: function (publicKey, name, icon) {
                    root.openContextMenu(publicKey, name, icon)
                }
                contactsModel: root.contactsStore.blockedContactsModel
                panelUsage: Constants.contactsPanelUsage.blockedContacts
            }
        }

        Component {
            id: loadingIndicator
            StatusLoadingIndicator {
                width: 12
                height: 12
            }
        }

        // TODO: Make BlockContactConfirmationDialog a dynamic component on a future refactor
        BlockContactConfirmationDialog {
            id: blockContactConfirmationDialog
            onBlockButtonClicked: {
                root.contactsStore.blockContact(blockContactConfirmationDialog.contactAddress)
                blockContactConfirmationDialog.close()
            }
        }


        // TODO: Make ConfirmationDialog a dynamic component on a future refactor
        ConfirmationDialog {
            id: removeContactConfirmationDialog
            header.title: qsTr("Remove contact")
            confirmationText: qsTr("Are you sure you want to remove this contact?")
            onConfirmButtonClicked: {
                if (Utils.getContactDetailsAsJson(removeContactConfirmationDialog.value).isAdded) {
                    root.contactsStore.removeContact(removeContactConfirmationDialog.value);
                }
                removeContactConfirmationDialog.close()
        }
    }

    Component {
        id: contactVerificationRequestPopupComponent
        ContactVerificationRequestPopup {
            onResponseSent: {
                root.contactsStore.acceptVerificationRequest(senderPublicKey, response)
            }
            onVerificationRefused: {
                root.contactsStore.declineVerificationRequest(senderPublicKey)
            }
            }
        }

        Loader {
            id: sendContactRequest
            width: parent.width
            height: parent.height
            active: false

            function open() {
                active = true
                sendContactRequest.item.open()
            }
            function close() {
                active = false
            }

            sourceComponent: SendContactRequestModal {
                anchors.centerIn: parent
                contactsStore: root.contactsStore
                onClosed: {
                    sendContactRequest.close();
                }
            }
        }
    }
}


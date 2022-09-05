import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13

import StatusQ.Layout 0.1

import utils 1.0
import shared.controls 1.0

import "popups"
import "panels"
import "views"
import "stores"

Item {
    id: root

    property bool hideSignPhraseModal: false
    property var store
    property var contactsStore
    property var emojiPopup: null
    property var sendModal

    function showSigningPhrasePopup(){
        if(!hideSignPhraseModal && !RootStore.hideSignPhraseModal){
            signPhrasePopup.open();
        }
    }

    SignPhraseModal {
        id: signPhrasePopup
        onRemindLaterClicked: hideSignPhraseModal = true
        onAcceptClicked: { RootStore.setHideSignPhraseModal(true); }
    }

    SeedPhraseBackupWarning {
        id: seedPhraseWarning
        width: parent.width
        anchors.top: parent.top
    }

    Component {
        id: cmpSavedAddresses
        SavedAddressesView {
            anchors.top: parent ? parent.top: undefined
            anchors.left: parent ? parent.left: undefined
            anchors.right: parent ? parent.right: undefined
            contactsStore: root.contactsStore
            sendModal: root.sendModal
        }
    }

    Component {
        id: walletContainer
        RightTabView {
            store: root.store
            contactsStore: root.contactsStore
            sendModal: root.sendModal
        }
    }


    StatusSectionLayout {
        anchors.top: seedPhraseWarning.bottom
        height: root.height - seedPhraseWarning.height
        width: root.width

        notificationCount: RootStore.unreadNotificationsCount
        onNotificationButtonClicked: Global.openActivityCenterPopup()
        Component.onCompleted: {
            // Read in RootStore
//            if(RootStore.firstTimeLogin){
//                RootStore.firstTimeLogin = false
//                RootStore.setInitialRange()
//            }
        }

        Timer {
            id: recentHistoryTimer
            interval: Constants.walletFetchRecentHistoryInterval
            running: true
            repeat: true
            onTriggered: RootStore.checkRecentHistory()
        }

        leftPanel: LeftTabView {
            id: leftTab
            anchors.fill: parent
            changeSelectedAccount: function(newIndex) {
                if (newIndex > RootStore.accounts) {
                    return
                }
                RootStore.switchAccount(newIndex)

            }
            showSavedAddresses: function(showSavedAddresses) {
                if(showSavedAddresses)
                    rightPanelStackView.replace(cmpSavedAddresses)
                else
                    rightPanelStackView.replace(walletContainer)
            }
            emojiPopup: root.emojiPopup
        }

        centerPanel: StackView {
            id: rightPanelStackView
            anchors.fill: parent
            anchors.leftMargin: 49
            anchors.rightMargin: 49
            initialItem: walletContainer
            replaceEnter: Transition {
                NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 400; easing.type: Easing.OutCubic }
            }
            replaceExit: Transition {
                NumberAnimation { property: "opacity"; from: 1; to: 0; duration: 400; easing.type: Easing.OutCubic }
            }
        }
    }
}

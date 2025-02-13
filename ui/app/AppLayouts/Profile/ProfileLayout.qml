import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13

import utils 1.0
import shared 1.0
import shared.panels 1.0

import "stores"
import "popups"
import "views"

import StatusQ.Layout 0.1
import StatusQ.Controls 0.1

StatusSectionLayout {
    id: root

    property ProfileSectionStore store
    property var globalStore
    property var systemPalette
    property var emojiPopup

    notificationCount: root.store.unreadNotificationsCount
    onNotificationButtonClicked: Global.openActivityCenterPopup()
    Component.onCompleted: {
        Global.privacyModuleInst = store.privacyStore.privacyModule
    }

    QtObject {
        id: d

        readonly property int topMargin: 0
        readonly property int bottomMargin: 56
        readonly property int leftMargin: 48
        readonly property int rightMargin: 48

        readonly property int contentWidth: 560
    }

    leftPanel: LeftTabView {
        id: leftTab
        store: root.store
        anchors.fill: parent
        anchors.topMargin: d.topMargin
        onMenuItemClicked: {
            if (profileContainer.currentItem.dirty) {
                event.accepted = true;
                profileContainer.currentItem.notifyDirty();
            }
        }
    }

    centerPanel: Item {
        anchors.fill: parent

        StackLayout {
            id: profileContainer

            readonly property var currentItem: (currentIndex >= 0 && currentIndex < children.length) ? children[currentIndex] : null

            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.bottomMargin: d.bottomMargin
            anchors.leftMargin: d.leftMargin
            anchors.rightMargin: d.rightMargin

            currentIndex: Global.settingsSubsection

            onCurrentIndexChanged: {
                if(visibleChildren[0] === ensContainer){
                    ensContainer.goToStart();
                }
            }

            MyProfileView {
                implicitWidth: parent.width
                implicitHeight: parent.height

                walletStore: root.store.walletStore
                profileStore: root.store.profileStore
                privacyStore: root.store.privacyStore
                sectionTitle: root.store.getNameForSubsection(Constants.settingsSubsection.profile)
                contentWidth: d.contentWidth
            }

            ContactsView {
                implicitWidth: parent.width
                implicitHeight: parent.height
                contactsStore: root.store.contactsStore
                sectionTitle: qsTr("Contacts")
                contentWidth: d.contentWidth
                backButtonName: root.store.getNameForSubsection(Constants.settingsSubsection.messaging)

                onBackButtonClicked: {
                    Global.changeAppSectionBySectionType(Constants.appSection.profile, Constants.settingsSubsection.messaging)
                }
            }

            EnsView {
                // TODO: we need to align structure for the entire this part using `SettingsContentBase` as root component
                // TODO: handle structure for this subsection to match style used in onther sections
                // using `SettingsContentBase` component as base.
                id: ensContainer
                implicitWidth: parent.width
                implicitHeight: parent.height

                ensUsernamesStore: root.store.ensUsernamesStore
                contactsStore: root.store.contactsStore
                stickersStore: root.store.stickersStore

                profileContentWidth: d.contentWidth
            }

            MessagingView {
                implicitWidth: parent.width
                implicitHeight: parent.height
                advancedStore: root.store.advancedStore
                messagingStore: root.store.messagingStore
                sectionTitle: root.store.getNameForSubsection(Constants.settingsSubsection.messaging)
                contactsStore: root.store.contactsStore
                contentWidth: d.contentWidth
            }

            WalletView {
                implicitWidth: parent.width
                implicitHeight: parent.height

                walletStore: root.store.walletStore
                emojiPopup: root.emojiPopup
                sectionTitle: root.store.getNameForSubsection(Constants.settingsSubsection.wallet)
                contentWidth: d.contentWidth
            }

            AppearanceView {
                implicitWidth: parent.width
                implicitHeight: parent.height

                appearanceStore: root.store.appearanceStore
                sectionTitle: root.store.getNameForSubsection(Constants.settingsSubsection.appearance)
                contentWidth: d.contentWidth
                systemPalette: root.systemPalette
            }

            LanguageView {
                implicitWidth: parent.width
                implicitHeight: parent.height

                languageStore: root.store.languageStore
                currencyStore: root.store.walletStore.currencyStore
                sectionTitle: root.store.getNameForSubsection(Constants.settingsSubsection.language)
                contentWidth: d.contentWidth
            }

            NotificationsView {
                implicitWidth: parent.width
                implicitHeight: parent.height

                notificationsStore: root.store.notificationsStore
                devicesStore: root.store.devicesStore
                sectionTitle: root.store.getNameForSubsection(Constants.settingsSubsection.notifications)
                contentWidth: d.contentWidth
            }

            DevicesView {
                implicitWidth: parent.width
                implicitHeight: parent.height

                devicesStore: root.store.devicesStore
                sectionTitle: root.store.getNameForSubsection(Constants.settingsSubsection.devicesSettings)
                contentWidth: d.contentWidth
            }

            BrowserView {
                implicitWidth: parent.width
                implicitHeight: parent.height

                store: root.store
                sectionTitle: root.store.getNameForSubsection(Constants.settingsSubsection.browserSettings)
                contentWidth: d.contentWidth
            }

            AdvancedView {
                implicitWidth: parent.width
                implicitHeight: parent.height

                advancedStore: root.store.advancedStore
                sectionTitle: root.store.getNameForSubsection(Constants.settingsSubsection.advanced)
                contentWidth: d.contentWidth
            }

            AboutView {
                implicitWidth: parent.width
                implicitHeight: parent.height

                store: root.store
                globalStore: root.globalStore
                sectionTitle: root.store.getNameForSubsection(Constants.settingsSubsection.about)
                contentWidth: d.contentWidth
            }

            CommunitiesView {
                implicitWidth: parent.width
                implicitHeight: parent.height

                profileSectionStore: root.store
                rootStore: root.globalStore
                contactStore: root.store.contactsStore
                sectionTitle: root.store.getNameForSubsection(Constants.settingsSubsection.communitiesSettings)
                contentWidth: d.contentWidth
            }

            KeycardView {
                implicitWidth: parent.width
                implicitHeight: parent.height

                keycardStore: root.store.keycardStore
                sectionTitle: root.store.getNameForSubsection(Constants.settingsSubsection.keycard)
                contentWidth: d.contentWidth
            }
        }
    } // Item

} // StatusAppTwoPanelLayout

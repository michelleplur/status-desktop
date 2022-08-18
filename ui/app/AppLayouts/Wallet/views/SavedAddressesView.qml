import QtQuick 2.13
import QtQuick.Controls 2.13

import utils 1.0

import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Utils 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Popups 0.1
import shared.controls 1.0

import "../stores"
import "../popups"
import "../controls"

Item {
    id: root
    anchors.leftMargin: Style.current.padding
    anchors.rightMargin: Style.current.padding

    property var sendModal
    property var contactsStore

    QtObject {
        id: _internal
        property bool loading: false
        property string error: ""
    }

    Item {
        id: header
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: btnAdd.height

        StatusBaseText {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            id: title
            text: qsTr("Saved addresses")
            font.weight: Font.Bold
            font.pixelSize: 28
            color: Theme.palette.directColor1
        }
        StatusButton {
            objectName: "addNewAddressBtn"
            id: btnAdd
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.verticalCenter: parent.verticalCenter
            size: StatusBaseButton.Size.Small
            font.weight: Font.Medium
            text: qsTr("Add new address")
            visible: !_internal.loading
            onClicked: {
                Global.openPopup(addEditSavedAddress)
            }
        }
        StatusLoadingIndicator {
            anchors.centerIn: parent
            visible: _internal.loading
            color: Theme.palette.directColor4
        }
    }

    Component {
        id: delegateSavedAddress
        StatusListItem {
            id: savedAddress
            title: name
            objectName: name
            subTitle: (ensName.length > 0 ? ensName + " \u2022 " : "")
                      + Utils.elideText(address, 6, 4)
            implicitWidth: parent.width
            color: "transparent"
            border.color: Theme.palette.baseColor5
            titleTextIcon: favourite ? "star-icon" : ""
            statusListItemComponentsSlot.spacing: 0
            property bool showButtons: sensor.containsMouse
            // TODO: fetch this from status-go
            readonly property string ensName: ""

            components: [
                StatusRoundButton {
                    icon.color: savedAddress.showButtons ? Theme.palette.directColor1 : Theme.palette.baseColor1
                    type: StatusRoundButton.Type.Tertiary
                    icon.name: "send"
                    onClicked: {
                        root.sendModal.open(address);
                    }
                },
                CopyToClipBoardButton {
                    type: StatusRoundButton.Type.Tertiary
                    icon.color: savedAddress.showButtons ? Theme.palette.directColor1 : Theme.palette.baseColor1
                    store: RootStore
                    textToCopy: address
                },
                StatusRoundButton {
                    icon.color: savedAddress.showButtons ? Theme.palette.directColor1 : Theme.palette.baseColor1
                    type: StatusRoundButton.Type.Tertiary
                    icon.name: favourite ? "unfavourite" : "favourite"
                    onClicked: _internal.error = RootStore.createOrUpdateSavedAddress(name, address, !favourite)
                },
                StatusRoundButton {
                    icon.color: savedAddress.showButtons ? Theme.palette.directColor1 : Theme.palette.baseColor1
                    type: StatusRoundButton.Type.Tertiary
                    icon.name: "more"
                    onClicked: {
                        editDeleteMenu.openMenu(name, address, favourite);
                    }
                }
            ]
        }
    }

    StatusPopupMenu {
        id: editDeleteMenu
        property string contactName
        property string contactAddress
        property bool storeFavourite
        function openMenu(name, address, favourite) {
            contactName = name
            contactAddress = address
            storeFavourite = favourite
            popup();
        }
        onClosed: {
            contactName = ""
            contactAddress = ""
            storeFavourite = false
        }
        StatusMenuItem {
            text: qsTr("Edit")
            objectName: "editSavedAddress"
            icon.name: "pencil-outline"
            onTriggered: {
                Global.openPopup(addEditSavedAddress,
                                 {
                                     edit: true,
                                     address: editDeleteMenu.contactAddress,
                                     name: editDeleteMenu.contactName,
                                     favourite: editDeleteMenu.storeFavourite
                                 })
            }
        }
        StatusMenuSeparator { }
        StatusMenuItem {
            text: qsTr("Delete")
            type: StatusMenuItem.Type.Danger
            icon.name: "delete"
            objectName: "deleteSavedAddress"
            onTriggered: {
                deleteAddressConfirm.name = editDeleteMenu.contactName
                deleteAddressConfirm.address = editDeleteMenu.contactAddress
                deleteAddressConfirm.favourite = editDeleteMenu.storeFavourite
                deleteAddressConfirm.open()
            }
        }
    }

    Component {
        id: addEditSavedAddress
        AddEditSavedAddressPopup {
            id: addEditModal
            anchors.centerIn: parent
            onClosed: destroy()
            contactsStore: root.contactsStore
            onSave: {
                _internal.loading = true
                _internal.error = RootStore.createOrUpdateSavedAddress(name, address, favourite)
                _internal.loading = false
                close()
            }
        }
    }

    StatusModal {
        id: deleteAddressConfirm
        property string address
        property string name
        property bool favourite
        // NOTE: the `text` property was created as a workaround because
        // setting StatusBaseText.text to `qsTr("...").arg("...")`
        // caused no text to render
        property string text: qsTr("Are you sure you want to remove '%1' from your saved addresses?").arg(name)
        anchors.centerIn: parent
        header.title: qsTr("Are you sure?")
        header.subTitle: name
        contentItem: StatusBaseText {
            anchors.centerIn: parent
            height: contentHeight + topPadding + bottomPadding
            text: deleteAddressConfirm.text
            font.pixelSize: 15
            color: Theme.palette.directColor1
            wrapMode: Text.Wrap
            topPadding: Style.current.padding
            rightPadding: Style.current.padding
            bottomPadding: Style.current.padding
            leftPadding: Style.current.padding
        }
        rightButtons: [
            StatusButton {
                text: qsTr("Cancel")
                onClicked: deleteAddressConfirm.close()
            },
            StatusButton {
                type: StatusBaseButton.Type.Danger
                objectName: "confirmDeleteSavedAddress"
                text: qsTr("Delete")
                onClicked: {
                    _internal.loading = true
                    _internal.error = RootStore.deleteSavedAddress(deleteAddressConfirm.address)
                    deleteAddressConfirm.close()
                    _internal.loading = false
                }
            }
        ]
    }

    SavedAddressesError {
        id: errorMessage
        anchors.top: header.bottom
        anchors.topMargin: Style.current.padding
        visible: _internal.error !== ""
        text: _internal.error
        height: visible ? 36 : 0
    }

    StatusBaseText {
        anchors.centerIn: parent
        visible: listView.count === 0
        color: Theme.palette.baseColor1
        text: qsTr("No saved addresses")
    }

    StatusListView {
        id: listView
        objectName: "savedAddresses"
        anchors.top: errorMessage.bottom
        anchors.topMargin: Style.current.padding
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Style.current.halfPadding
        anchors.right: parent.right
        anchors.left: parent.left
        visible: listView.count > 0
        spacing: 5
        model: RootStore.savedAddresses
        delegate: delegateSavedAddress
    }
}

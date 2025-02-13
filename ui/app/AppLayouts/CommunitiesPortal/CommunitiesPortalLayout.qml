import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Popups 0.1
import StatusQ.Popups.Dialog 0.1
import StatusQ.Layout 0.1

import utils 1.0
import shared.popups 1.0
import shared.panels 1.0

import "controls"
import "stores"
import "popups"

StatusSectionLayout {
    id: root
    objectName: "communitiesPortalLayout"

    property CommunitiesStore communitiesStore: CommunitiesStore {}
    property var importCommunitiesPopup: importCommunitiesPopupComponent
    property var createCommunitiesPopup: createCommunitiesPopupComponent
    property int contentPrefferedWidth: 100

    notificationCount: root.communitiesStore.unreadNotificationsCount
    onNotificationButtonClicked: Global.openActivityCenterPopup()

    QtObject {
        id: d

        property string searchText: ""
        property int layoutVMargin: 70
        property int layoutHMargin: 64
        property int titlePixelSize: 28
        property int subtitlePixelSize: 17

        function navigateToCommunity(communityId) {
            root.communitiesStore.setActiveCommunity(communityId)
        }
    }

    centerPanel: Item {
        implicitWidth: parent.width
        implicitHeight: parent.height
        clip: true

        StatusScrollView {
            contentHeight: column.height + d.layoutVMargin
            contentWidth: root.contentPrefferedWidth - d.layoutHMargin

            ColumnLayout {
                id: column
                width: parent.availableWidth
                height: childrenRect.height
                spacing: 18

                StatusBaseText {
                    Layout.leftMargin: d.layoutHMargin
                    text: qsTr("Find community")
                    font.weight: Font.Bold
                    font.pixelSize: d.titlePixelSize
                    color: Theme.palette.directColor1
                }

                RowLayout {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 38
                    spacing: Style.current.bigPadding

                    StatusInput {
                        id: searcher
                        implicitWidth: 327
                        Layout.leftMargin: d.layoutHMargin
                        Layout.alignment: Qt.AlignVCenter
                        enabled: false // Out of scope
                        placeholderText: qsTr("Search")
                        input.asset.name: "search"
                        leftPadding: 0
                        rightPadding: 0
                        topPadding: 0
                        bottomPadding: 0
                        minimumHeight: 36
                        maximumHeight: 36
                        text: d.searchText
                        onTextChanged: {
                            console.warn("TODO: Community Cards searcher algorithm.")
                            // 1. Filter Community Cards by title, description or tags category.
                            // 2. Once some filter is applyed, update main tags row only showing the tags that are part of the categories of the filtered Community Cards.
                        }
                    }

                    // Just a row filler to fit design
                    Item { Layout.fillWidth: true }

                    StatusButton {
                        id: importBtn
                        Layout.fillHeight: true
                        text: qsTr("Import using key")
                        verticalPadding: 0
                        onClicked: Global.openPopup(importCommunitiesPopupComponent)
                    }

                    StatusButton {
                        id: createBtn
                        objectName: "createCommunityButton"
                        Layout.fillHeight: true
                        verticalPadding: 0
                        text: qsTr("Create New Community")
                        onClicked: {
                            if (localAccountSensitiveSettings.isDiscordImportToolEnabled) {
                              Global.openPopup(chooseCommunityCreationTypePopupComponent)
                            } else {
                              Global.openPopup(createCommunitiesPopupComponent)
                            }
                        }
                    }
                }

                CommunityTagsRow {
                    tags: root.communitiesStore.communityTags
                    Layout.leftMargin: d.layoutHMargin
                    Layout.fillWidth: true
                }

                StatusBaseText {
                    Layout.leftMargin: d.layoutHMargin
                    Layout.topMargin: 20
                    text: qsTr("Featured")
                    font.weight: Font.Bold
                    font.pixelSize: d.subtitlePixelSize
                    color: Theme.palette.directColor1
                }

                GridLayout {
                    id: featuredGrid
                    Layout.leftMargin: d.layoutHMargin
                    columns: 3
                    columnSpacing: Style.current.padding
                    rowSpacing: Style.current.padding

                    Repeater {
                        model: root.communitiesStore.curatedCommunitiesModel
                        delegate: StatusCommunityCard {
                            visible: model.featured
                            locale: communitiesStore.locale
                            communityId: model.id
                            loaded: model.available
                            logo: model.icon
                            name: model.name
                            description: model.description
                            members: model.members
                            popularity: model.popularity
                            // <out of scope> categories:  model.categories

                            onClicked: { d.navigateToCommunity(communityId) }
                        }
                    }
                }

                StatusBaseText {
                    Layout.leftMargin: d.layoutHMargin
                    Layout.topMargin: 20
                    text: qsTr("Popular")
                    font.weight: Font.Bold
                    font.pixelSize: d.subtitlePixelSize
                    color: Theme.palette.directColor1
                }

                GridLayout {
                    Layout.leftMargin: d.layoutHMargin
                    columns: 3
                    columnSpacing: Style.current.padding
                    rowSpacing: Style.current.padding

                    Repeater {
                        model: root.communitiesStore.curatedCommunitiesModel
                        delegate: StatusCommunityCard {
                            visible: !model.featured
                            locale: communitiesStore.locale
                            communityId: model.id
                            loaded: model.available
                            logo: model.icon
                            name: model.name
                            description: model.description
                            members: model.members
                            popularity: model.popularity
                            // <out of scope> categories:  model.categories

                            onClicked: { d.navigateToCommunity(communityId) }
                        }
                    }
                }
            }
        }
    }

    Component {
        id: importCommunitiesPopupComponent
        ImportCommunityPopup {
            anchors.centerIn: parent
            store: root.communitiesStore
            onClosed: {
                destroy()
            }
        }
    }

    Component {
        id: createCommunitiesPopupComponent
        CreateCommunityPopup {
            anchors.centerIn: parent
            store: root.communitiesStore
            onClosed: {
                destroy()
            }
        }
    }

    Component {
        id: chooseCommunityCreationTypePopupComponent
        StatusDialog {
            id: chooseCommunityCreationTypePopup
            title: qsTr("Create new community")
            horizontalPadding: 40
            verticalPadding: 60
            footer: null
            onClosed: destroy()

            contentItem: RowLayout {
                spacing: 20
                CommunityBanner {
                    text: qsTr("Create a new Status community")
                    buttonText: qsTr("Create new")
                    icon.name: "favourite"
                    onButtonClicked: {
                        chooseCommunityCreationTypePopup.close()
                        Global.openPopup(createCommunitiesPopupComponent)
                    }
                }
                CommunityBanner {
                    text: qsTr("Import existing Discord community into Status")
                    buttonText: qsTr("Import existing")
                    icon.name: "download"
                    onButtonClicked: {
                        chooseCommunityCreationTypePopup.close()
                        Global.openPopup(createCommunitiesPopupComponent, {isDiscordImport: true})
                    }
                }
            }
        }
    }
}

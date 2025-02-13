import QtQuick 2.13
import QtQuick.Layouts 1.13

import StatusQ.Components 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core 0.1
import StatusQ.Controls 0.1

import utils 1.0
import shared.controls 1.0

import "../../stores"
import "../../controls"

Item {
    id: root

    signal goBack()

    CollectibleDetailsHeader {
        id: collectibleHeader
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        asset.name: RootStore.collectiblesStore.collectibleImageUrl
        asset.isImage: true
        primaryText: RootStore.collectiblesStore.name
        secondaryText: RootStore.collectiblesStore.collectibleId
        onGoBack: root.goBack()
    }

    ColumnLayout {
        anchors.top: collectibleHeader.bottom
        anchors.topMargin: 46
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        spacing: Style.current.padding

        Row {
            id: collectibleImageDetails
            Layout.preferredWidth: parent.width
            spacing: 24

            StatusRoundedImage {
                id: collectibleimage
                width: 253
                height: 253
                radius: 2
                color: RootStore.collectiblesStore.backgroundColor
                border.color: Theme.palette.directColor8
                border.width: 1
                image.source: RootStore.collectiblesStore.imageUrl
            }
            StatusBaseText {
                id: collectibleText
                width: parent.width - collectibleimage.width - Style.current.bigPadding
                height: collectibleimage.height

                text: RootStore.collectiblesStore.description
                color: Theme.palette.directColor1
                font.pixelSize: 15
                lineHeight: 22
                lineHeightMode: Text.FixedHeight
                elide: Text.ElideRight
                wrapMode: Text.Wrap
            }
        }

        StatusTabBar {
            id: collectiblesDetailsTab
            Layout.fillWidth: true
            Layout.topMargin: Style.current.xlPadding
            visible: RootStore.collectiblesStore.properties.count > 0

            StatusTabButton {
                leftPadding: 0
                width: implicitWidth
                text: qsTr("Properties")
            }
        }

        StackLayout {
            Flow {
                width: parent.width
                spacing: 10
                Repeater {
                    model: RootStore.collectiblesStore.properties
                    InformationTile {
                        maxWidth: parent.width
                        primaryText: model.traitType
                        secondaryText: model.value
                    }
                }
            }
        }
    }
}

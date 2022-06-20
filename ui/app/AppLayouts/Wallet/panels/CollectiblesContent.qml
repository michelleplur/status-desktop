import QtQuick 2.13
import QtQuick.Controls 2.13
import QtGraphicalEffects 1.13
import QtQml.Models 2.13

import utils 1.0
import shared.panels 1.0

import StatusQ.Controls 0.1

ScrollView {
    id: collectiblesContent

    readonly property int imageSize: Style.dp(164)
    property var collectiblesModal
    property string buttonText: "View in Cryptokitties"
    property var getLink: function () {}
    property var collectibles: []

    signal reloadCollectibles(string collectibleType)

    height: visible ? contentLoader.item.height : 0
    width: parent.width
    ScrollBar.vertical.policy: ScrollBar.AlwaysOff
    ScrollBar.horizontal.policy: ScrollBar.AsNeeded
    clip: true

    Loader {
        id: contentLoader
        active: true
        width: parent.width
        height: collectiblesContent.imageSize
        sourceComponent: !!error ? errorComponent : collectiblesContentComponent
    }

    Component {
        id: errorComponent

        Item  {
            width: parent.width
            height: collectiblesContent.imageSize

            Item {
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                height: childrenRect.height
                width: somethingWentWrongText.width

                StyledText {
                    id: somethingWentWrongText
                    //% "Something went wrong"
                    text: qsTrId("something-went-wrong")
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: Style.current.secondaryText
                    font.pixelSize: Style.current.additionalTextSize
                }

                StatusButton {
                    //% "Reload"
                    text: qsTrId("reload")
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: somethingWentWrongText.bottom
                    anchors.topMargin: Style.current.halfPadding
                    onClicked: {
                        reloadCollectibles(collectibleType);
                    }
                }
            }
        }

    }

    Component {
        id: collectiblesContentComponent

        Row {
            id: contentRow
            bottomPadding: Style.current.padding
            spacing: Style.current.padding

            Repeater {
                model: collectibles

                Item {
                    width: collectibleImage.width
                    height: collectibleImage.height
                    clip: true

                    RoundedImage {
                        id: collectibleImage
                        width: collectiblesContent.imageSize
                        height: collectiblesContent.imageSize
                        border.width: 1
                        border.color: Style.current.border
                        radius: Style.dp(16)
                        source: modelData.image
                        fillMode: Image.PreserveAspectCrop
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.horizontalCenter: parent.horizontalCenter
                        onClicked: {
                            collectiblesModal.openModal({
                                                       name: modelData.name,
                                                       id: modelData.id,
                                                       description: modelData.description,
                                                       buttonText: collectiblesContent.buttonText,
                                                       link: collectiblesContent.getLink(modelData.id, modelData.externalUrl),
                                                       image: modelData.image
                                                   })
                        }
                    }
                }
            }
        }
    }
}

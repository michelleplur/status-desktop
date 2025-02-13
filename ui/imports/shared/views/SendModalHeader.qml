import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import StatusQ.Controls.Validators 0.1

import utils 1.0

import StatusQ.Controls 0.1
import StatusQ.Popups 0.1
import StatusQ.Components 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1 as StatusQUtils

import "../controls"
import "../views"

StatusFloatingButtonsSelector {
    id: floatingHeader

    property var selectedAccount
    property var changeSelectedAccount: function(){}

    repeater.objectName: "accountsListFloatingHeader"
    
    signal updatedSelectedAccount(var account)

    QtObject {
        id: d
        property var firstModelData: null
    }

    delegate: Rectangle {
        width: button.width
        height: button.height
        radius: 8
        visible: floatingHeader.visibleIndices.includes(index) && walletType !== Constants.watchWalletType
        color: Theme.palette.baseColor3
        StatusButton {
            id: button
            topPadding: 8
            bottomPadding: 0
            implicitHeight: 32
            leftPadding: 4
            text: name
            objectName: name
            asset.emoji: !!emoji ? emoji: ""
            asset.emojiSize: StatusQUtils.Emoji.size.middle
            icon.name: !emoji ? "filled-account": ""
            normalColor: "transparent"
            hoverColor: Theme.palette.statusFloatingButtonHighlight
            highlighted: index === floatingHeader.currentIndex
            onClicked: {
                changeSelectedAccount(index)
                floatingHeader.currentIndex = index
            }
            Component.onCompleted: {
                // On startup make the preseected wallet in the floating menu,
                // and if the selectedAccount is watch only then select 0th item
                if(index === 0) {
                    d.firstModelData = model
                }

                if(name !== floatingHeader.selectedAccount.name) {
                    return
                }

                if(name === floatingHeader.selectedAccount.name) {
                    if(walletType !== Constants.watchWalletType) {
                        // If the selected index wont be displayed, added it to the visible indices
                        if(index > 2) {
                            visibleIndices = [0, 1, index]
                        }
                        floatingHeader.currentIndex = index
                    }
                    else {
                        changeSelectedAccount(0)
                        floatingHeader.currentIndex = 0
                    }
                }
            }
        }
    }
    popupMenuDelegate: StatusListItem {
        implicitWidth: 272
        title: name
        subTitle: currencyBalance
        asset.emoji: !!emoji ? emoji: ""
        asset.color: model.color
        asset.name: !emoji ? "filled-account": ""
        asset.letterSize: 14
        asset.isLetterIdenticon: !!model.emoji
        asset.bgColor: Theme.palette.indirectColor1
        onClicked: {
            changeSelectedAccount(index)
            floatingHeader.itemSelected(index)
        }
        visible: !floatingHeader.visibleIndices.includes(index) && walletType !== Constants.watchWalletType
    }
}


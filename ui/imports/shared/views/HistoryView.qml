import QtQuick 2.13
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.3

import StatusQ.Core 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import StatusQ.Core.Theme 0.1

import utils 1.0

import "../panels"
import "../popups"
import "../stores"
import "../controls"

ColumnLayout {
    id: historyView

    property var account
    property int pageSize: 20 // number of transactions per page
    property bool isLoading: false

    function fetchHistory() {
        if (RootStore.isFetchingHistory(historyView.account.address)) {
            isLoading = true
        } else {
            RootStore.loadTransactionsForAccount(historyView.account.address, pageSize)
        }
    }

    Connections {
        target: RootStore.history
        onLoadingTrxHistoryChanged: function(isLoading, address) {
            if (historyView.account.address.toLowerCase() === address.toLowerCase()) {
                isLoading = isLoading
            }
        }
    }

    Loader {
        id: loadingImg
        active: isLoading
        sourceComponent: loadingImageComponent
        Layout.alignment: Qt.AlignRight | Qt.AlignTop
        Layout.rightMargin: Style.current.padding
    }

    StyledText {
        id: nonArchivalNodeError
        Layout.alignment: Qt.AlignTop

        visible: RootStore.isNonArchivalNode
        text: qsTr("Status Desktop is connected to a non-archival node. Transaction history may be incomplete.")
        font.pixelSize: Style.current.primaryTextFontSize
        color: Style.current.danger
    }

    StyledText {
        id: noTxs
        visible: transactionListRoot.count === 0
        text: qsTr("No transactions found")
        font.pixelSize: Style.current.primaryTextFontSize
    }

    StatusListView {
        id: transactionListRoot
        Layout.alignment: Qt.AlignTop
        Layout.topMargin: nonArchivalNodeError.visible || noTxs.visible ? Style.current.padding : 0
        Layout.bottomMargin: Style.current.padding
        Layout.fillWidth: true
        Layout.fillHeight: true

        model: RootStore.historyTransactions
        delegate: Loader {
            width: parent.width
            sourceComponent: isTimeStamp ? dateHeader : transactionDelegate
            onLoaded:  {
                item.modelData = model
            }
        }

        ScrollBar.vertical: StatusScrollBar {}

        footer:  StatusButton {
            id: loadMoreButton
            anchors.horizontalCenter: parent.horizontalCenter

            text: qsTr("Load More")
            // TODO: handle case when requested limit === transaction count -- there
            // is currently no way to know that there are no more results
            enabled: !isLoading && RootStore.historyTransactions.hasMore 
            onClicked: fetchHistory()
        }
    }

    Component {
        id: dateHeader
        StatusListItem {
            property var modelData
            height: 40
            title: LocaleUtils.formatDate(modelData.timestamp * 1000, Locale.ShortFormat)
            statusListItemTitle.color: Theme.palette.baseColor1
            color: Theme.palette.statusListItem.backgroundColor
            sensor.enabled: false
        }
    }

    Component {
        id: transactionDelegate
        TransactionDelegate {
            isIncoming: modelData !== undefined ? modelData.to === account.address: false
            currentCurrency: RootStore.currentCurrency
            cryptoValue: modelData !== undefined ? RootStore.hex2Eth(modelData.value) : ""
            fiatValue: RootStore.getFiatValue(cryptoValue, resolvedSymbol, RootStore.currentCurrency)
            networkIcon: modelData !== undefined ? RootStore.getNetworkIcon(modelData.chainId) : ""
            networkColor: modelData !== undefined ? RootStore.getNetworkColor(modelData.chainId) : ""
            networkName: modelData !== undefined ? RootStore.getNetworkShortName(modelData.chainId) : ""
            symbol: modelData !== undefined ? RootStore.findTokenSymbolByAddress(modelData.contract) : ""
            transferStatus: modelData !== undefined ? RootStore.hex2Dec(modelData.txStatus) : ""
            shortTimeStamp: modelData !== undefined ? LocaleUtils.formatTime(modelData.timestamp * 1000, Locale.ShortFormat) : ""
            savedAddressName: modelData !== undefined ? RootStore.getNameForSavedWalletAddress(modelData.to) : ""
            onClicked: {
                transactionModal.transaction = modelData
                transactionModal.open()
            }
        }
    }

    Component {
        id: loadingImageComponent
        StatusLoadingIndicator {}
    }

    TransactionModal {
        id: transactionModal
    }
}

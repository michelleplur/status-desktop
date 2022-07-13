import QtQuick 2.13
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.13

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1

import utils 1.0

import "../stores"

Item {
    id: root

    property KeycardStore keycardStore

    Item {
        anchors.top: parent.top
        anchors.bottom: footerWrapper.top
        anchors.left: parent.left
        anchors.right: parent.right

        ColumnLayout {
            anchors.centerIn: parent
            spacing: Style.current.padding

            Image {
                id: image
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredHeight: sourceSize.height
                Layout.preferredWidth: sourceSize.width
                fillMode: Image.PreserveAspectFit
                antialiasing: true
                mipmap: true
            }

            StatusBaseText {
                id: title
                Layout.alignment: Qt.AlignHCenter
                font.pixelSize: Constants.keycard.general.titleFontSize1
                font.weight: Font.Bold
            }

            StatusBaseText {
                id: info
                Layout.alignment: Qt.AlignHCenter
                font.pixelSize: Constants.keycard.general.infoFontSize
                wrapMode: Text.WordWrap
            }
        }
    }

    Item {
        id: footerWrapper
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: Constants.keycard.general.footerWrapperHeight

        ColumnLayout {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: Style.current.bigPadding

            StatusButton {
                id: button
                visible: text.length > 0
                Layout.alignment: Qt.AlignHCenter
                focus: true
                onClicked: {
                    if(keycardStore.keycardModule.flowState === Constants.keycard.state.keycardNotEmptyState ||
                            keycardStore.keycardModule.flowState === Constants.keycard.state.keycardLockedFactoryResetState ||
                            keycardStore.keycardModule.flowState === Constants.keycard.state.maxPairingSlotsReachedState){
                        keycardStore.factoryReset()
                    }
                    else if(keycardStore.keycardModule.flowState === Constants.keycard.state.keycardIsEmptyState){
                        keycardStore.cancelCurrentAndRunLoadAccountFlowInMode(Constants.keycard.mode.generateNewKeysMode)
                    }
                    else if(keycardStore.keycardModule.flowState === Constants.keycard.state.maxPinRetriesReachedState ||
                            keycardStore.keycardModule.flowState === Constants.keycard.state.keycardLockedRecoverState){
                        keycardStore.nextState()
                    }
                    else if(keycardStore.keycardModule.flowState === Constants.keycard.state.recoverKeycardState){
                        keycardStore.cancelCurrentAndRunLoadAccountFlowInMode(Constants.keycard.mode.importSeedPhraseMode)
                    }
                }
            }

            StatusBaseText {
                id: link
                visible: text.length > 0
                Layout.alignment: Qt.AlignHCenter
                font.pixelSize: Constants.keycard.general.buttonFontSize
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true
                    onEntered: {
                        parent.font.underline = true
                    }
                    onExited: {
                        parent.font.underline = false
                    }
                    onClicked: {
                        if(keycardStore.keycardModule.flowState === Constants.keycard.state.keycardNotEmptyState ||
                                keycardStore.keycardModule.flowState === Constants.keycard.state.keycardLockedFactoryResetState ||
                                keycardStore.keycardModule.flowState === Constants.keycard.state.maxPairingSlotsReachedState){
                            keycardStore.switchCard()
                        }
                        else if(keycardStore.keycardModule.flowState === Constants.keycard.state.recoverKeycardState){
                            console.warn("Recover with PUK")
                        }
                    }
                }
            }
        }
    }

    states: [
        State {
            name: Constants.keycard.state.keycardNotEmptyState
            when: keycardStore.keycardModule.flowState === Constants.keycard.state.keycardNotEmptyState
            PropertyChanges {
                target: image
                source: Style.svg("keycard/card3@2x")
            }
            PropertyChanges {
                target: title
                text: qsTr("This Keycard already stores keys")
            }
            PropertyChanges {
                target: info
                text: qsTr("To generate new keys, you will need to perform a factory reset first")
                color: Theme.palette.directColor1
            }
            PropertyChanges {
                target: button
                text: qsTr("Factory reset")
                type: StatusBaseButton.Type.Normal
            }
            PropertyChanges {
                target: link
                text: qsTr("Insert another Keycard")
                color: Theme.palette.primaryColor1
            }
        },
        State {
            name: Constants.keycard.state.keycardIsEmptyState
            when: keycardStore.keycardModule.flowState === Constants.keycard.state.keycardIsEmptyState
            PropertyChanges {
                target: image
                source: Style.svg("keycard/card-error3@2x")
            }
            PropertyChanges {
                target: title
                text: ""
            }
            PropertyChanges {
                target: info
                text: qsTr("The keycard is empty")
                color: Theme.palette.dangerColor1
            }
            PropertyChanges {
                target: button
                text: qsTr("Genarate new keys for this Keycard")
                type: StatusBaseButton.Type.Normal
            }
            PropertyChanges {
                target: link
                text: ""
            }
        },
        State {
            name: Constants.keycard.state.keycardLockedFactoryResetState
            when: keycardStore.keycardModule.flowState === Constants.keycard.state.keycardLockedFactoryResetState
            PropertyChanges {
                target: image
                source: Style.svg("keycard/card-error3@2x")
            }
            PropertyChanges {
                target: title
                text: qsTr("Keycard locked and already stores keys")
            }
            PropertyChanges {
                target: info
                text: qsTr("The Keycard you have inserted is locked, you will need to factory reset it before proceeding")
                color: Theme.palette.directColor1
            }
            PropertyChanges {
                target: button
                text: qsTr("Factory reset")
                type: StatusBaseButton.Type.Normal
            }
            PropertyChanges {
                target: link
                text: qsTr("Insert another Keycard")
                color: Theme.palette.primaryColor1
            }
        },
        State {
            name: Constants.keycard.state.maxPairingSlotsReachedState
            when: keycardStore.keycardModule.flowState === Constants.keycard.state.maxPairingSlotsReachedState
            PropertyChanges {
                target: image
                source: Style.svg("keycard/card-error3@2x")
            }
            PropertyChanges {
                target: title
                text: ""
            }
            PropertyChanges {
                target: info
                text: qsTr("Max pairing slots reached for this keycard")
                color: Theme.palette.dangerColor1
            }
            PropertyChanges {
                target: button
                text: qsTr("Factory reset")
                type: StatusBaseButton.Type.Normal
            }
            PropertyChanges {
                target: link
                text: qsTr("Insert another Keycard")
                color: Theme.palette.primaryColor1
            }
        },
        State {
            name: Constants.keycard.state.maxPinRetriesReachedState
            when: keycardStore.keycardModule.flowState === Constants.keycard.state.maxPinRetriesReachedState ||
                  keycardStore.keycardModule.flowState === Constants.keycard.state.keycardLockedRecoverState
            PropertyChanges {
                target: image
                source: Style.svg("keycard/card-error3@2x")
            }
            PropertyChanges {
                target: title
                text: ""
            }
            PropertyChanges {
                target: info
                text: qsTr("Keycard locked")
                color: Theme.palette.dangerColor1
            }
            PropertyChanges {
                target: button
                text: qsTr("Recover your Keycard")
                type: StatusBaseButton.Type.Danger
            }
            PropertyChanges {
                target: link
                text: ""
            }
        },
        State {
            name: Constants.keycard.state.recoverKeycardState
            when: keycardStore.keycardModule.flowState === Constants.keycard.state.recoverKeycardState
            PropertyChanges {
                target: image
                source: Style.svg("keycard/card-error3@2x")
            }
            PropertyChanges {
                target: title
                text: qsTr("Recover your Keycard")
            }
            PropertyChanges {
                target: info
                text: ""
            }
            PropertyChanges {
                target: button
                text: qsTr("Recover with seed phrase")
                type: StatusBaseButton.Type.Danger
            }
            PropertyChanges {
                target: link
                text: qsTr("Recover with PUK")
                color: Theme.palette.dangerColor1
            }
        }
    ]
}

import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1
import StatusQ.Controls 0.1
import StatusQ.Popups 0.1

import utils 1.0

import "./states"

StatusModal {
    id: root

    property var sharedKeycardModule

    width: Constants.keycard.general.popupWidth
    height: {
        if (!root.sharedKeycardModule.keyPairStoredOnKeycardIsKnown) {
            if (root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.setupNewKeycard) {
                if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keycardMetadataDisplay ||
                        root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.factoryResetConfirmationDisplayMetadata) {
                    return Constants.keycard.general.popupBiggerHeight
                }
            }
            if (root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.factoryReset) {
                if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keycardMetadataDisplay ||
                        root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.factoryResetConfirmationDisplayMetadata) {
                    return Constants.keycard.general.popupBiggerHeight
                }
            }
        }
        return Constants.keycard.general.popupHeight
    }
    margins: Style.current.halfPadding
    anchors.centerIn: parent
    closePolicy: d.disablePopupClose? Popup.NoAutoClose : Popup.CloseOnEscape

    header.title: {
        if (root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.setupNewKeycard) {
            return qsTr("Set up a new Keycard with an existing account")
        }
        if (root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.factoryReset) {
            return qsTr("Factory reset a Keycard")
        }
        if (root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.authentication) {
            return qsTr("Authenticate")
        }
        return ""
    }

    QtObject {
        id: d
        property bool primaryButtonEnabled: false
        property bool seedPhraseRevealed: false
        readonly property bool disablePopupClose: root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.readingKeycard ||
                                                  root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.recognizedKeycard ||
                                                  root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.migratingKeyPair ||
                                                  (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keyPairMigrateSuccess &&
                                                   root.sharedKeycardModule.migratingProfileKeyPair())

        onDisablePopupCloseChanged: {
            hasCloseButton = !disablePopupClose
        }
    }

    onClosed: {
        root.sharedKeycardModule.currentState.doTertiaryAction()
    }

    contentItem: Item {
        Loader {
            id: loader
            anchors.fill: parent
            sourceComponent: {
                if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.pluginReader ||
                        root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.insertKeycard ||
                        root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keycardInserted ||
                        root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.readingKeycard ||
                        root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keyPairMigrateSuccess ||
                        root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keyPairMigrateFailure ||
                        root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.migratingKeyPair ||
                        root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.factoryResetSuccess ||
                        root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keycardEmptyMetadata ||
                        root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keycardEmpty ||
                        root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keycardNotEmpty ||
                        root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keycardLocked ||
                        root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.notKeycard ||
                        root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.wrongKeycard ||
                        root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.biometricsReadyToSign ||
                        root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.maxPinRetriesReached ||
                        root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.recognizedKeycard ||
                        root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keycardMetadataDisplay ||
                        root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.biometricsPasswordFailed ||
                        root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.biometricsPinFailed ||
                        root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.biometricsPinInvalid)
                {
                    return initComponent
                }
                if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.factoryResetConfirmation ||
                        root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.factoryResetConfirmationDisplayMetadata)
                {
                    return confirmationComponent
                }
                if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.selectExistingKeyPair)
                {
                    return selectKeyPairComponent
                }
                if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.createPin ||
                        root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.repeatPin ||
                        root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.enterPin ||
                        root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.wrongPin ||
                        root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.wrongKeychainPin ||
                        root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.pinSet ||
                        root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.pinVerified)
                {
                    return keycardPinComponent
                }
                if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.enterSeedPhrase ||
                        root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.wrongSeedPhrase)
                {
                    return enterSeedPhraseComponent
                }
                if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.seedPhraseDisplay)
                {
                    return seedPhraseComponent
                }
                if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.seedPhraseEnterWords)
                {
                    return enterSeedPhraseWordsComponent
                }
                if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.enterPassword ||
                        root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.enterBiometricsPassword ||
                        root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.wrongBiometricsPassword ||
                        root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.wrongPassword) {
                    return passwordComponent
                }

                return undefined
            }
        }

        Component {
            id: initComponent
            KeycardInit {
                sharedKeycardModule: root.sharedKeycardModule

                Component.onCompleted: {
                    d.primaryButtonEnabled = false
                }
            }
        }

        Component {
            id: confirmationComponent
            KeycardConfirmation {
                sharedKeycardModule: root.sharedKeycardModule

                Component.onCompleted: {
                    d.primaryButtonEnabled = false
                }

                onConfirmationUpdated: {
                    d.primaryButtonEnabled = value
                }
            }
        }

        Component {
            id: selectKeyPairComponent
            SelectKeyPair {
                sharedKeycardModule: root.sharedKeycardModule

                Component.onCompleted: {
                    d.primaryButtonEnabled = false
                }

                onKeyPairSelected: {
                    d.primaryButtonEnabled = true
                }
            }
        }

        Component {
            id: keycardPinComponent
            KeycardPin {
                sharedKeycardModule: root.sharedKeycardModule

                Component.onCompleted: {
                    d.primaryButtonEnabled = false
                }

                onPinUpdated: {
                    d.primaryButtonEnabled = pin.length === Constants.keycard.general.keycardPinLength
                }
            }
        }

        Component {
            id: enterSeedPhraseComponent
            EnterSeedPhrase {
                sharedKeycardModule: root.sharedKeycardModule

                Component.onCompleted: {
                    d.primaryButtonEnabled = false
                }

                onValidation: {
                    d.primaryButtonEnabled = result
                }
            }
        }

        Component {
            id: seedPhraseComponent
            SeedPhrase {
                sharedKeycardModule: root.sharedKeycardModule

                Component.onCompleted: {
                    hideSeed = !d.seedPhraseRevealed
                    d.primaryButtonEnabled = Qt.binding(function(){ return d.seedPhraseRevealed })
                }

                onSeedPhraseRevealed: {
                    d.seedPhraseRevealed = true
                }
            }
        }

        Component {
            id: enterSeedPhraseWordsComponent
            EnterSeedPhraseWords {
                sharedKeycardModule: root.sharedKeycardModule

                Component.onCompleted: {
                    d.primaryButtonEnabled = false
                }

                onValidation: {
                    d.primaryButtonEnabled = result
                }
            }
        }

        Component {
            id: passwordComponent
            EnterPassword {
                sharedKeycardModule: root.sharedKeycardModule

                Component.onCompleted: {
                    d.primaryButtonEnabled = false
                }

                onPasswordValid: {
                    d.primaryButtonEnabled = valid
                }
            }
        }
    }

    leftButtons: [
        StatusBackButton {
            id: backButton
            visible: root.sharedKeycardModule.currentState.displayBackButton
            height: Constants.keycard.general.footerButtonsHeight
            width: height
            onClicked: {
                root.sharedKeycardModule.currentState.backAction()
            }
        }
    ]

    rightButtons: [
        StatusButton {
            id: tertiaryButton
            height: Constants.keycard.general.footerButtonsHeight
            text: qsTr("Cancel")
            visible: {
                if (root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.setupNewKeycard) {
                    if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.selectExistingKeyPair ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keycardNotEmpty ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keycardLocked ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keycardEmptyMetadata ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.enterPin ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.wrongPin ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.maxPinRetriesReached ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.factoryResetConfirmation ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.factoryResetConfirmationDisplayMetadata ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.factoryResetSuccess ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.pinVerified ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keycardMetadataDisplay) {
                        return true
                    }
                }
                if (root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.factoryReset) {
                    if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.pinVerified ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.enterPin ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.wrongPin ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.maxPinRetriesReached ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keycardMetadataDisplay ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keycardEmptyMetadata ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.factoryResetConfirmationDisplayMetadata ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.factoryResetConfirmation) {
                        return true
                    }
                }
                if (root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.authentication) {
                    if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.pluginReader ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.readingKeycard ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.insertKeycard ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keycardInserted ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keycardEmpty ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.wrongPin ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.wrongKeychainPin ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.biometricsReadyToSign ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.maxPinRetriesReached ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.notKeycard ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.wrongKeycard ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.enterPassword ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.wrongPassword ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.biometricsPasswordFailed ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.biometricsPinFailed ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.biometricsPinInvalid ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.enterBiometricsPassword ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.wrongBiometricsPassword ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.enterPin)
                        return true
                }

                return false
            }

            onClicked: {
                root.sharedKeycardModule.currentState.doTertiaryAction()
            }
        },
        StatusButton {
            id: secondaryButton
            height: Constants.keycard.general.footerButtonsHeight
            text: {
                if (root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.authentication) {
                    if (root.sharedKeycardModule.loggedInUserUsesBiometricLogin()) {
                        if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.enterPassword ||
                                root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.wrongPassword)
                            return qsTr("Use biometrics instead")
                        if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.biometricsPasswordFailed)
                            return qsTr("Use password instead")
                        if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.enterPin ||
                                root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.wrongPin)
                            return qsTr("Use biometrics")
                        if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.pluginReader ||
                                root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.insertKeycard ||
                                root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keycardInserted ||
                                root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.readingKeycard ||
                                root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.biometricsReadyToSign ||
                                root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.notKeycard ||
                                root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.biometricsPinFailed ||
                                root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.biometricsPinInvalid ||
                                root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.wrongKeycard ||
                                root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keycardEmpty)
                            return qsTr("Use PIN")
                    }
                }
                return ""
            }
            visible: {
                if (root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.authentication) {
                    if (root.sharedKeycardModule.loggedInUserUsesBiometricLogin()) {
                        if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.pluginReader ||
                                root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.insertKeycard ||
                                root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keycardInserted ||
                                root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.readingKeycard ||
                                root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.enterPassword ||
                                root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.enterPin ||
                                root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.biometricsPasswordFailed ||
                                root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.biometricsPinFailed ||
                                root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.biometricsPinInvalid ||
                                root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.wrongPassword ||
                                root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.wrongPin ||
                                root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.biometricsReadyToSign ||
                                root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.notKeycard ||
                                root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.wrongKeycard ||
                                root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keycardEmpty)
                            return true
                    }
                }
                return false
            }
            enabled: {
                if (root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.authentication) {
                    if (root.sharedKeycardModule.loggedInUserUsesBiometricLogin() &&
                            (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.pluginReader ||
                             root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.insertKeycard ||
                             root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keycardInserted ||
                             root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.readingKeycard ||
                             root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.notKeycard ||
                             root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.wrongKeycard ||
                             root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keycardEmpty))
                        return false
                }
                return true
            }

            onClicked: {
                root.sharedKeycardModule.currentState.doSecondaryAction()
            }
        },
        StatusButton {
            id: primaryButton
            height: Constants.keycard.general.footerButtonsHeight
            text: {
                if (root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.setupNewKeycard) {
                    if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.pluginReader ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.readingKeycard ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.insertKeycard ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keycardInserted ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.recognizedKeycard ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.createPin ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.repeatPin ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.pinSet) {
                        return qsTr("Input seed phrase")
                    }
                    if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.seedPhraseEnterWords) {
                        return qsTr("Yes, migrate key pair to this Keycard")
                    }
                    if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.enterSeedPhrase) {
                        return qsTr("Yes, migrate key pair to Keycard")
                    }
                    if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.wrongSeedPhrase) {
                        return qsTr("Try entering seed phrase again")
                    }
                    if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keycardNotEmpty) {
                        return qsTr("Check what is stored on this Keycard")
                    }
                    if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.enterPin ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.wrongPin) {
                        return qsTr("I don’t know the PIN")
                    }
                    if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.factoryResetConfirmation ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.factoryResetConfirmationDisplayMetadata) {
                        return qsTr("Factory reset this Keycard")
                    }
                    if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.selectExistingKeyPair ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keycardLocked ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keycardEmptyMetadata ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.factoryResetSuccess ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.seedPhraseDisplay ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.pinVerified ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keycardMetadataDisplay) {
                        return qsTr("Next")
                    }
                    if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.maxPinRetriesReached) {
                        return qsTr("Unlock Keycard")
                    }
                    if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.migratingKeyPair ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keyPairMigrateFailure) {
                        return qsTr("Done")
                    }
                    if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keyPairMigrateSuccess) {
                        if (root.sharedKeycardModule.migratingProfileKeyPair())
                            return qsTr("Restart app & sign in using your new Keycard")
                        return qsTr("Done")
                    }
                    return qsTr("Cancel")
                }
                if (root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.factoryReset) {
                    if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.enterPin ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.wrongPin) {
                        return qsTr("I don’t know the PIN")
                    }
                    if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.factoryResetConfirmation ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.factoryResetConfirmationDisplayMetadata) {
                        return qsTr("Factory reset this Keycard")
                    }
                    if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.pinVerified ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keycardMetadataDisplay ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keycardEmptyMetadata) {
                        return qsTr("Next")
                    }
                    if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.maxPinRetriesReached) {
                        return qsTr("Unlock Keycard")
                    }
                    if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.readingKeycard ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.factoryResetSuccess) {
                        return qsTr("Done")
                    }
                    return qsTr("Cancel")
                }
                if (root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.authentication) {
                    if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.pluginReader ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.readingKeycard ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.insertKeycard ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keycardInserted ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keycardEmpty ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.wrongPin ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.notKeycard ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.biometricsReadyToSign ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.wrongKeycard ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.enterPassword ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.wrongPassword ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.enterPin) {
                        return qsTr("Authenticate")
                    }
                    if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.enterBiometricsPassword ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.wrongBiometricsPassword) {
                        return qsTr("Update password & authenticate")
                    }
                    if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.wrongKeychainPin) {
                        return qsTr("Update PIN & authenticate")
                    }
                    if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.biometricsPasswordFailed ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.biometricsPinFailed ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.biometricsPinInvalid) {
                        return qsTr("Try biometrics again")
                    }
                    if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.maxPinRetriesReached) {
                        return qsTr("Unlock Keycard")
                    }
                }
                return ""
            }
            enabled: {
                if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.readingKeycard ||
                        root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.migratingKeyPair) {
                    if (d.disablePopupClose) {
                        return false
                    }
                }
                if (root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.setupNewKeycard) {
                    if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.selectExistingKeyPair ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.factoryResetConfirmation ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.factoryResetConfirmationDisplayMetadata ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.seedPhraseDisplay ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.seedPhraseEnterWords ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.enterSeedPhrase) {
                        return d.primaryButtonEnabled
                    }
                    if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.pluginReader ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.insertKeycard ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keycardInserted ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.recognizedKeycard ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.createPin ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.repeatPin) {
                        return false
                    }
                }
                if (root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.factoryReset) {
                    if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.factoryResetConfirmation ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.factoryResetConfirmationDisplayMetadata) {
                        return d.primaryButtonEnabled
                    }
                }
                if (root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.authentication) {
                    if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.pluginReader ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.readingKeycard ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.insertKeycard ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keycardInserted ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keycardEmpty ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.wrongPin ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.wrongKeychainPin ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.notKeycard ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.wrongKeycard ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.enterPassword ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.wrongPassword ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.enterBiometricsPassword ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.wrongBiometricsPassword ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.enterPin) {
                        return d.primaryButtonEnabled
                    }
                    if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.maxPinRetriesReached) {
                        return true
                    }
                }
                return true
            }
            icon.name: {
                if (root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.setupNewKeycard) {
                    if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.seedPhraseEnterWords ||
                            root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.enterSeedPhrase) {
                            if (root.sharedKeycardModule.loggedInUserUsesBiometricLogin())
                                return "touch-id"
                            if (root.sharedKeycardModule.isProfileKeyPairMigrated())
                                return "keycard"
                            return "password"
                    }
                }
                if (root.sharedKeycardModule.currentState.flowType === Constants.keycardSharedFlow.authentication) {
                    if (root.sharedKeycardModule.loggedInUserUsesBiometricLogin()) {
                        if (root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.pluginReader ||
                                root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.insertKeycard ||
                                root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keycardInserted ||
                                root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.readingKeycard ||
                                root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.biometricsPasswordFailed ||
                                root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.biometricsPinFailed ||
                                root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.biometricsPinInvalid ||
                                root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.biometricsReadyToSign ||
                                root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.notKeycard ||
                                root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.wrongKeycard ||
                                root.sharedKeycardModule.currentState.stateType === Constants.keycardSharedState.keycardEmpty)
                            return "touch-id"
                    }
                }
                return ""
            }

            onClicked: {
                root.sharedKeycardModule.currentState.doPrimaryAction()
            }
        }
    ]
}

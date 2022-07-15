import QtQuick 2.13
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.13

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Controls.Validators 0.1

import utils 1.0

import "../stores"

Item {
    id: root

    property KeycardStore keycardStore
    property string kcData: keycardStore.keycardModule.keycardData

    Component.onCompleted: {
        d.allEntriesValid = false
        d.pukArray = Array(d.pukLength)
        d.pukArray.fill("")
    }

    QtObject {
        id: d

        readonly property int pukLength: 12
        property var pukArray: []
        property bool allEntriesValid: false
        readonly property int rowSpacing: Style.current.padding

        function updateValidity() {
            for(let i = 0; i < pukLength; ++i) {
                if(pukArray[i].length !== 1) {
                    allEntriesValid = false
                    return
                }
            }
            allEntriesValid = true
        }

        function submitPuk() {
            let puk = d.pukArray.join("")
            if(keycardStore.checkKeycardPuk(puk)) {
                keycardStore.nextState()
            }
        }
    }

    Item {
        anchors.top: parent.top
        anchors.bottom: footerWrapper.top
        anchors.left: parent.left
        anchors.right: parent.right

        ColumnLayout {
            anchors.centerIn: parent
            spacing: Style.current.padding

            StatusBaseText {
                id: title
                Layout.alignment: Qt.AlignHCenter
                font.pixelSize: Constants.keycard.general.titleFontSize1
                font.weight: Font.Bold
                color: Theme.palette.directColor1
                text: qsTr("Enter PUK code to recover Keycard")
            }

            RowLayout {
                id: rowLayout
                Layout.alignment: Qt.AlignHCenter
                spacing: d.rowSpacing

                Component.onCompleted: {
                    for (var i = 0; i < children.length - 1; ++i) {
                        if(children[i] && children[i].input && children[i+1] && children[i+1].input){
                            children[i].input.tabNavItem = children[i+1].input.edit
                        }
                    }
                    if(children.length > 0){
                        children[0].input.edit.forceActiveFocus()
                    }
                }

                Repeater {
                    model: d.pukLength
                    delegate: StatusInput {
                        Layout.preferredWidth: Constants.keycard.general.pukCellWidth
                        Layout.preferredHeight: Constants.keycard.general.pukCellHeight
                        input.acceptReturn: true
                        validators: [
                            StatusRegularExpressionValidator {
                                regularExpression: /[0-9]/
                                errorMessage: ""
                            },
                            StatusMinLengthValidator {
                                minLength: 1
                                errorMessage: ""
                            }
                        ]

                        onTextChanged: {
                            text = text.trim()
                            if(text.length >= 1) {
                                text = text.charAt(0);
                            }
                            if(Utils.isDigit(text)) {
                                let nextInd = index+1
                                if(nextInd <= rowLayout.children.length - 1 &&
                                        rowLayout.children[nextInd] &&
                                        rowLayout.children[nextInd].input){
                                    rowLayout.children[nextInd].input.edit.forceActiveFocus()
                                }
                            }
                            else                            {
                                text = ""
                            }
                            d.pukArray[index] = text
                            d.updateValidity()
                        }

                        onKeyPressed: {
                            if(input.edit.keyEvent === Qt.Key_Backspace){
                                if (text == ""){
                                    let prevInd = index-1
                                    if(prevInd >= 0){
                                        rowLayout.children[prevInd].input.edit.forceActiveFocus()
                                    }
                                }
                            }
                            else if (input.edit.keyEvent === Qt.Key_Return ||
                                     input.edit.keyEvent === Qt.Key_Enter) {
                                if(d.allEntriesValid) {
                                    event.accepted = true
                                    d.submitPuk()
                                }
                            }
                        }
                    }
                }
            }

            StatusBaseText {
                id: info
                Layout.alignment: Qt.AlignHCenter
                font.pixelSize: Constants.keycard.general.infoFontSize
                color: Theme.palette.dangerColor1
                horizontalAlignment: Qt.AlignHCenter
            }
        }
    }

    Item {
        id: footerWrapper
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: Constants.keycard.general.footerWrapperHeight

        StatusButton {
            anchors.top: parent.top
            anchors.topMargin: Style.current.padding
            anchors.horizontalCenter: parent.horizontalCenter
            enabled: d.allEntriesValid
            text: qsTr("Recover Keycard")
            onClicked: {
                d.submitPuk()
            }
        }
    }

    states: [
        State {
            name: Constants.keycard.state.enterKeycardPukState
            when: keycardStore.keycardModule.flowState === Constants.keycard.state.enterKeycardPukState
            PropertyChanges {
                target: info
                text: ""
            }
        },
        State {
            name: Constants.keycard.state.wrongKeycardPukState
            when: keycardStore.keycardModule.flowState === Constants.keycard.state.wrongKeycardPukState
            PropertyChanges {
                target: info
                text: root.kcData === "1"?
                          qsTr("Invalid PUK code, 1 attempt remaining") :
                          qsTr("Invalid PUK code, %1 attempts remaining").arg(root.kcData)
            }
            StateChangeScript {
                script: d.allEntriesValid = false
            }
        }
    ]
}

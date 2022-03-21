import QtQuick 2.13

import utils 1.0
import "."

import StatusQ.Core 0.1
import StatusQ.Controls 0.1

StatusInput {
    id: searchBox
    //% "Search"
    input.placeholderText: qsTrId("search")
    input.icon.name: "search"
    input.implicitHeight: 36
    input.clearable: true
    leftPadding: 0
    rightPadding: 0
}

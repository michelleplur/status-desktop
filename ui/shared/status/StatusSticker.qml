import QtQuick 2.3
import "../../shared" as Shared
import "../../imports"

Loader {
    property color color
    property int contentType: -1
    property string stickerData: sticker
    property int imageHeight: 140
    property int imageWidth: 140
    signal loaded()

    id: root
    active: contentType === Constants.stickerType

    sourceComponent: Component {
        Shared.ImageLoader {
            color: root.color
            onLoaded: root.loaded()

            width: imageWidth
            height: this.visible ? imageHeight : 0
            source: this.visible ? ("https://ipfs.infura.io/ipfs/" + stickerData) : ""
        }
    }
}
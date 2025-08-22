import QtQuick

import qs.modules

Item {
    id: root

    required property var screen

    function getImage() {
        var wallpaper = Configs.bg.wallpaper;

        var orientation = screen.orientation;

        // ? Qt.PrimaryOrientation
        var isLandscape = orientation == Qt.LandscapeOrientation || orientation == Qt.InvertedLandscapeOrientation;

        return isLandscape ? wallpaper.landscape : wallpaper.portrait;
    }

    anchors.fill: parent

    Image {
        anchors.fill: parent

        asynchronous: true

        fillMode: Image.PreserveAspectCrop

        source: root.getImage()
    }
}

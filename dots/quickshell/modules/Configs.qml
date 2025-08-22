pragma Singleton

import Qt.labs.platform
import QtQuick

import Quickshell
import Quickshell.Io

import qs.configs

Singleton {
    id: root

    property alias bg: adapter.background

    FileView {
        path: `${StandardPaths.writableLocation(StandardPaths.GenericConfigLocation)}/quickshell.json`

        watchChanges: true
        onFileChanged: reload()

        JsonAdapter {
            id: adapter

            property Background background: Background {}
        }
    }
}

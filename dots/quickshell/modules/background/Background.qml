import QtQuick

import Quickshell
import Quickshell.Wayland

import qs.modules

Loader {
    id: root

    active: Configs.bg.enable

    sourceComponent: Variants {
        model: Quickshell.screens

        PanelWindow {
            id: bg

            required property ShellScreen modelData

            screen: modelData

            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }
            exclusionMode: ExclusionMode.Ignore

            color: "transparent" // niri overview.backdrop-color

            WlrLayershell.namespace: "qs-bg"
            WlrLayershell.layer: WlrLayer.Background

            Wallpaper {
                screen: bg.screen
            }
        }
    }
}

import Quickshell.Io

JsonObject {
    property bool enable: true

    property Wallpaper wallpaper: Wallpaper {}

    component Wallpaper: JsonObject {
        property string landscape
        property string portrait: landscape
    }
}

{
  home =

    { lib, config, ... }:

    let
      cfg = config.programs.ghostty;
    in
    {
      config = lib.mkIf cfg.enable {
        programs.ghostty = {
          settings = {
            font-family = [
              "Maple Mono CN"
              "Maple Mono TC"
              "Maple Mono JP"
              "Maple Mono KR"

              "Symbols Nerd Font Mono"
            ];

            # Monokai Soda, Monokai Vivid
            theme = "light:Monokai Classic,dark:Monokai Remastered";

            window-padding-x = "8";
            window-padding-y = "8";

            background-opacity = 0.8;
            background-blur = true;

            cursor-style = "underline";

            quick-terminal-position = "top";
            quick-terminal-size = "75%";

            gtk-tabs-location = "bottom";
            gtk-toolbar-style = "raised";
            # gtk-titlebar-style = "tabs";

            # TRACK: https://github.com/ghostty-org/ghostty/issues/8681
            shell-integration-features = [ "no-cursor" ];

            keybind = [
              # BAD: niri !impl global-shortcuts
              "global:ctrl+grave_accent=toggle_quick_terminal"

              "alt+d=text:cd ..\\n"
            ];

            quit-after-last-window-closed = true;
            quit-after-last-window-closed-delay = "10m";

            auto-update = "off";
          };
        };

        programs.fuzzel.settings.main.terminal = "${lib.getExe cfg.package} {cmd}";
      };
    };
}

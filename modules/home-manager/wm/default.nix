{
  pkgs,
  lib,
  config,
  ...
}:

let
  inherit (lib)
    mkIf
    mkMerge
    mkDefault

    isHyprland
    isNiri
    ;
in
{
  imports = [
    ./kde.nix
    ./hyprland.nix
    ./niri.nix

    ./waybar.nix
  ];

  config = mkMerge [
    (mkIf lib.my.haveAnyWM (
      let
        cursor = {
          package = pkgs.capitaine-cursors; # bibata-cursors, material-cursors
          name = "capitaine-cursors-white"; # Bibata-Modern-Ice
          size = 24;
        };
      in
      {
        home.packages = [ pkgs.fcitx5-material-color ];

        dconf.settings = {
          "org/gnome/desktop/privacy" = {
            remember-app-usage = false;
            remember-recent-files = false;
          };
          "org/gnome/desktop/interface" = {
            color-scheme = "prefer-dark";
          };
        };

        fonts.fontconfig.enable = true;

        programs.kitty.enable = mkDefault true;

        programs.firefox.enable = mkDefault true;

        home.pointerCursor = {
          gtk.enable = true;
        } // cursor;

        programs.niri.settings.cursor = {
          theme = cursor.name;
          size = cursor.size;
        };

        gtk = {
          enable = true;
          theme = {
            package = pkgs.fluent-gtk-theme;
            name = "Fluent-purple-Dark";
          };
          iconTheme = {
            package = pkgs.papirus-icon-theme;
            name = "Papirus-Dark";
          };
        };
      }
    ))

    (mkIf (isHyprland || isNiri) {
      services.playerctld.enable = true;

      services.mako = {
        enable = true;
        settings = {
          defaultTimeout = 10000;

          borderColor = "#884DFFFF";
          borderRadius = 3;
          backgroundColor = "#00000033";
          font = "Sarasa Term Slab SC 10";
        };
      };

      programs.fuzzel = {
        enable = true;
        settings = {
          main = {
            font = "Sarasa Mono Slab SC:slant=italic";
            icon-theme = config.gtk.iconTheme.name;
            horizontal-pad = 16;
            vertical-pad = 8;

            lines = 12;
            tabs = 4;
          };
          colors = rec {
            background = "161b22cc";
            text = "f5f5f5ff";
            selection = "30563fcc";
            selection-text = "3fb950ff";

            match = "c38000ff";
            selection-match = match;

            border = "0088ffff";
          };
          border.radius = 0;
        };
      };

      programs.tofi.settings = {
        font = "Sarasa Mono Slab SC";
        font-size = 12;

        outline-width = 0;

        background-color = "#1B1D1EBF";

        border-width = 2;
        border-color = "#884DFF";

        history = false;
      };

      programs.waybar.enable = mkDefault true;
    })
  ];
}

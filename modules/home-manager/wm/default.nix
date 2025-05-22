{
  pkgs,
  lib,
  config,
  osConfig,
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

        # FIX: https://github.com/nix-community/home-manager/pull/7045
        fonts.fontconfig.enable = !osConfig.fonts.fontconfig.enable;

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

        qt = {
          enable = true;
          platformTheme.name = "gtk3";
        };
      }
    ))

    (mkIf (isHyprland || isNiri) {
      services.playerctld.enable = true;

      # notifications
      services.mako = {
        enable = true;
        settings = {
          default-timeout = 5000;
          group-by = "app-name,summary";

          icon-path = "${pkgs.papirus-icon-theme}/share/icons/${config.gtk.iconTheme.name}";

          outer-margin = 3;

          font = "Sarasa Fixed Slab SC Italic 13px";
          border-color = "#884DFFFF";
          background-color = "#00000080";

          icon-location = "right";
          text-alignment = "right";
        };
      };

      # launcher
      programs.fuzzel = {
        enable = true;
        settings = {
          main = {
            font = "Monaspace Radon Frozen";
            icon-theme = config.gtk.iconTheme.name;
            horizontal-pad = 8;
            vertical-pad = 16;

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

      # launcher
      programs.tofi.settings = {
        font = "Sarasa Fixed Slab SC";
        font-size = 13;

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

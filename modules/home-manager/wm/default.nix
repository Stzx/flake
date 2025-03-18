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

  config = (
    mkMerge [
      (mkIf lib.my.haveAnyWM {
        home.packages = [ pkgs.fcitx5-material-color ];

        dconf.settings."org/gnome/desktop/privacy" = {
          remember-recent-files = false;
        };

        fonts.fontconfig.enable = true;

        programs.kitty.enable = mkDefault true;

        programs.firefox.enable = mkDefault true;
      })

      (mkIf (isHyprland || isNiri) {
        home.pointerCursor = {
          package = pkgs.capitaine-cursors;
          name = "capitaine-cursors";
        };

        services.mako = {
          enable = true;
          defaultTimeout = 10000;

          borderColor = "#884DFFFF";
          borderRadius = 3;
          backgroundColor = "#00000033";
          font = "Sarasa Term Slab SC 10";
        };

        programs.fuzzel = {
          enable = true;
          settings = {
            main = {
              font = "Sarasa Mono Slab SC:slant=italic";
              icon-theme = "Papirus";
              horizontal-pad = 24;
              vertical-pad = 8;

              lines = 10;
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

        dconf.settings = {
          "org/gnome/desktop/interface" = {
            gtk-theme = "Breeze-Dark";
            color-scheme = "prefer-dark";
            icon-theme = "Papirus";
            cursor-theme = config.home.pointerCursor.name;
          };
        };
      })
    ]
  );
}

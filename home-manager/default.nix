{ lib
, pkgs
, config
, ...
}:

{
  imports = with lib;
    (optional isHyprland {
      home.pointerCursor = {
        package = pkgs.capitaine-cursors;
        name = "capitaine-cursors";
      };

      dconf.settings = {
        "org/gnome/desktop/interface" = {
          gtk-theme = "Breeze-Dark";
          color-scheme = "prefer-dark";
          icon-theme = "Papirus";
          cursor-theme = config.home.pointerCursor.name;
        };
      };
    }) ++ (optional isHyprland {
      # NOTE: https://github.com/Alexays/Waybar/issues/2381
      systemd.user.services.waybar.Unit = rec {
        After = [ "wireplumber.service" ];
        Wants = After;
      };

      home.packages = with pkgs.kdePackages; [
        breeze
        breeze-gtk

        qt6ct
      ];

      services.playerctld.enable = true;

      wayland.windowManager.hyprland.enable = true;
    }) ++ (my.listNeedWM [
      {
        home.packages = with pkgs; [
          fcitx5-material-color
        ];

        dconf.settings = {
          "org/gnome/desktop/privacy" = {
            remember-recent-files = false;
          };
        };

        fonts.fontconfig.enable = true;
      }
    ]);

  xdg.enable = true;

  programs = {
    home-manager.enable = true;

    zsh.enable = true;

    git.enable = true;

    neovim.enable = true;
  } // lib.my.attrNeedWM {
    kitty.enable = lib.mkDefault true;

    firefox.enable = true;
  };
}

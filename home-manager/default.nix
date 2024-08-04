{ lib
, pkgs
, config
, ...
}:

{

  imports = [ ]
    ++ lib.optionals lib.my.isHyprland [
    {

      home.packages = with pkgs.kdePackages; [
        breeze
        breeze-gtk

        qt6ct
      ];

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

      services.playerctld.enable = true;

      wayland.windowManager.hyprland.enable = true;
    }
  ] ++ lib.my.listNeedWM [
    {
      home.packages = with pkgs; [
        fcitx5-material-color
      ];

      fonts.fontconfig.enable = true;
    }
  ];

  xdg.enable = true;

  programs = {
    home-manager.enable = true;

    zsh.enable = true;

    git.enable = true;

    neovim.enable = true;
  } // lib.attrNeedWM {
    kitty.enable = true;

    firefox.enable = true;
  };
}

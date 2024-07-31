{ lib
, pkgs
, ...
}:

{

  imports = [ ] ++ lib.my.listNeedWM [
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

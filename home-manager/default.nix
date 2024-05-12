{ lib
, ...
}:

{
  xdg.enable = true;

  fonts.fontconfig.enable = true;

  programs = {
    home-manager.enable = true;
    zsh.enable = true;
    neovim.enable = true;
  } // lib.attrNeedDE {
    kitty.enable = true;
    firefox.enable = true;
  };
}

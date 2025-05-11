{ pkgs, ... }:

{
  home.packages = with pkgs; [ numbat ];

  programs = {
    home-manager.enable = true;

    zsh.enable = true;

    git = {
      enable = true;
      delta.options = {
        line-numbers = true;
        side-by-side = true;
      };
    };

    neovim.enable = true;
  };
}

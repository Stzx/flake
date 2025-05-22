{ pkgs, osConfig, ... }:

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

  xdg.configFile."MangoHud/MangoHud.conf" = {
    enable = osConfig.services.flatpak.enable;
    text = ''
      background_alpha=0.25

      gpu_power
      arch
      histogram
      show_fps_limit
      display_server

      wine
      winesync
    '';
  };
}

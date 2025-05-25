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
      cellpadding_y=0.05

      cpu_load_change
      gpu_load_change

      cpu_temp
      cpu_mhz

      gpu_temp
      gpu_power

      dynamic_frame_timing
      histogram

      engine_short_names
      display_server

      winesync
    '';
  };
}

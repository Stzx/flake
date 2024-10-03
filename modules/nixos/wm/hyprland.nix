{
  pkgs,
  lib,
  config,
  ...
}:

let
  inherit (lib) mkIf mkOption types;

  cfg = config.features.wm;
in
{
  options.features.wm.hyprland = mkOption {
    type = types.bool;
    default = false;
  };

  config = mkIf cfg.hyprland {
    xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ]; # file picker

    programs.hyprland = {
      enable = true;
      xwayland.enable = false;
    };
  };
}

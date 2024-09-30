{
  pkgs,
  lib,
  config,
  ...
}:

let
  cfg = config.features.wm;
in
{
  options.features.wm.hyprland = lib.mkOption {
    type = lib.types.bool;
    default = false;
  };

  config = lib.mkIf cfg.hyprland {
    xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ]; # file picker

    programs.hyprland = {
      enable = true;
      xwayland.enable = false;
    };
  };
}

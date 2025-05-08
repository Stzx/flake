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
  options.features.wm.niri = mkOption {
    type = types.bool;
    default = false;
  };

  config = mkIf cfg.niri {
    xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];

    niri-flake.cache.enable = false;

    programs.niri.enable = true;
  };
}

{
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
    programs.hyprland = {
      enable = true;
      xwayland.enable = false;
    };
  };
}

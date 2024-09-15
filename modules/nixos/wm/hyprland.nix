{ pkgs
, lib
, config
, ...
}:

let
  cfg = config.features.wm;
in
{
  options.features.wm.hyprland = lib.mkOption {
    type = lib.types.bool;
    default = false;
  };

  config = lib.mkIf cfg.hyprland { programs.hyprland.enable = true; };
}

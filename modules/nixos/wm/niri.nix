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
  options.features.wm.niri = mkOption {
    type = types.bool;
    default = false;
  };

  config = mkIf cfg.niri {
    niri-flake.cache.enable = false;

    programs.niri.enable = true;
  };
}

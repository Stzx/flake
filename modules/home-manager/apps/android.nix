{ config, lib, pkgs, ... }:

let
  cfg = config.want;

  tools = [ ]
    ++ lib.optional cfg.adb pkgs.android-tools
    ++ lib.optional cfg.scrcpy pkgs.scrcpy;
in
{
  options.want = {
    adb = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Install ADB";
    };
    scrcpy = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Install Scrcpy";
    };
  };

  config = lib.mkIf (tools != [ ]) { home.packages = tools; };
}

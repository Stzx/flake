{
  pkgs,
  lib,
  config,
  osConfig,
  ...
}:

let
  enable = config.programs.scrcpy;
in
{
  options.programs = {
    scrcpy = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
  };

  config = lib.mkIf enable {
    assertions = [
      {
        assertion = osConfig.programs.adb.enable;
        message = "ADB is not enabled. Please ensure that ADB is enabled.";
      }
    ];

    home.packages = [
      pkgs.scrcpy
    ];
  };
}

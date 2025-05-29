{
  home =
    {
      pkgs,
      lib,
      config,
      sysCfg,
      ...
    }:

    {
      options.programs = {
        scrcpy = lib.mkOption {
          type = lib.types.bool;
          default = false;
        };
      };

      config = lib.mkIf config.programs.scrcpy {
        assertions = [
          {
            assertion = sysCfg.programs.adb.enable;
            message = "ADB is not enabled";
          }
        ];

        home.packages = [ pkgs.scrcpy ];
      };
    };
}

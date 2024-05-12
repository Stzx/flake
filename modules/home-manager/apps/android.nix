{ pkgs
, lib
, config
, ...
}:

let
  cfg = config.programs;

  any = cfg.adb || cfg.scrcpy;
in
{
  options.programs = {
    adb = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
    scrcpy = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
  };

  config = lib.mkIf any {
    programs.zsh.oh-my-zsh.plugins = [ "adb" ];

    home.packages = [ ]
      ++ lib.optional any pkgs.android-tools
      ++ lib.optional cfg.scrcpy pkgs.scrcpy;
  };
}

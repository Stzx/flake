{
  home =
    {
      pkgs,
      lib,
      config,
      sysCfg,
      wmCfg,
      ...
    }:

    let
      inherit (lib) types mkIf;

      cfg = config.programs.quickshell;

      quickshellPath = "${sysCfg.environment.sessionVariables.__FLAKE}/dots/quickshell";
    in
    {
      options.programs.quickshell = with types; {
        cfgs = lib.mkOption {
          type = attrs;
          default = { };
        };
        mode = lib.mkOption {
          type = enum [
            "supplemental"
            "exclusive"
          ];
          default = "supplemental";
          description = "activate modules";
        };
      };

      config = mkIf config.programs.quickshell.enable (
        lib.mkMerge [
          {
            xdg.configFile = {
              "quickshell.json".text = builtins.toJSON cfg.cfgs;
              "quickshell" = {
                recursive = true;
                source = config.lib.file.mkOutOfStoreSymlink quickshellPath;
              };
            };

            programs.quickshell = {
              systemd = {
                enable = true;
                target = "graphical-session.target";
              };
            };
          }
        ]
      );
    };
}

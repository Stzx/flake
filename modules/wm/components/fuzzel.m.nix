{
  home =
    {
      pkgs,
      lib,
      config,
      sysCfg,
      ...
    }:

    let
      cfg = config.programs.fuzzel;
    in
    {
      options.programs.fuzzel = {
        wrapper = lib.mkOption {
          type = with lib.types; nullOr lines;
          default = null;
        };
      };

      config = lib.mkIf cfg.enable {
        programs.fuzzel.settings = {
          main = {
            font = "Monaspace Radon Var";
            icon-theme = config.gtk.iconTheme.name;

            hide-prompt = true;

            line-height = 24;

            horizontal-pad = 32;
            vertical-pad = 16;
          }
          // lib.optionalAttrs (cfg.wrapper != null) {
            launch-prefix = "${pkgs.writeShellScript "fuzzel-wrapper" cfg.wrapper}";
          };
          border.radius = 0;
          colors = rec {
            background = "161b22cc";
            text = "f5f5f5ff";
            selection = "30563fcc";
            selection-text = "3fb950ff";

            match = "c38000ff";
            selection-match = match;

            border = "0088ffff";
          };
        };
      };
    };
}

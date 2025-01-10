{
  lib,
  config,
  dots,
  ...
}:

let
  inherit (lib) mkIf mkMerge;

  cfg = config.programs;

  alacrittyCfg = cfg.alacritty;
  kittyCfg = cfg.kitty;

  zshEnable = cfg.zsh.enable;
  zshPkg = cfg.zsh.package;
in
mkMerge [
  (mkIf kittyCfg.enable {
    programs.kitty = {
      themeFile = "Monokai";
      extraConfig = ''
        font_family Sarasa Term Slab SC

        background_opacity 0.8
        background_blur 0

        cursor_shape underline

        tab_bar_align center
        tab_bar_edge top

        shell_integration no-cursor

        allow_remote_control no

        ${lib.optionalString zshEnable "shell ${zshPkg}/bin/zsh"}
      '';
    };
  })

  (mkIf alacrittyCfg.enable {
    xdg.configFile."alacritty/theme.yml".source =
      dots + /alacritty/alacritty-theme/themes/monokai_charcoal.yaml;

    programs.alacritty = {
      settings =
        {
          import = [ "~/.config/alacritty/theme.yml" ];
          window = {
            dimensions = {
              columns = 160;
              lines = 32;
            };
            opacity = 0.75;
            startup_mode = "Maximized";
          };
          cursor.style = {
            shape = "Underline";
            blinking = "On";
          };
        }
        // lib.optionalAttrs zshEnable {
          shell.program = "${zshPkg}/bin/zsh";
        };
    };
  })
]

{ lib
, config
, dots
, ...
}:

let
  cfg = config.programs;

  zshEnable = cfg.zsh.enable;
  zshPkg = cfg.zsh.package;
in
lib.mkMerge [
  (lib.mkIf cfg.alacritty.enable {
    xdg.configFile."alacritty/theme.yml".source = dots + /alacritty/alacritty-theme/themes/monokai_charcoal.yaml;

    programs.alacritty = {
      settings = {
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
      } // lib.optionalAttrs zshEnable {
        shell.program = "${zshPkg}/bin/zsh";
      };
    };
  })

  (lib.mkIf cfg.kitty.enable {
    programs.kitty = {
      theme = "Monokai";
      extraConfig = ''
        font_family ComicShannsMono Nerd Font

        cursor_shape underline

        tab_bar_align center
        tab_bar_edge top

        shell_integration no-cursor

        allow_remote_control no

        ${lib.optionalString zshEnable "shell ${zshPkg}/bin/zsh"}
      '';
    };
  })
]

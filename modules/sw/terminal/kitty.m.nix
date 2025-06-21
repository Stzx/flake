{
  home =
    {
      lib,
      config,
      dots,
      ...
    }:
    {
      config = lib.mkIf config.programs.kitty.enable {
        programs.kitty = {
          themeFile = "Monokai";
          extraConfig = ''
            font_family Sarasa Term Slab SC

            background_opacity 0.8
            background_blur 0

            cursor_shape underline

            window_padding_width 3
            tab_bar_align center
            tab_bar_edge bottom

            shell_integration no-cursor

            allow_remote_control no
          '';
        };

        programs.zsh.shellAliases = {
          icat = "kitty +kitten icat";
          kssh = "kitty +kitten ssh";
        };
      };
    };
}

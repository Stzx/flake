{
  home =
    {
      pkgs,
      lib,
      config,
      dots,
      ...
    }:

    let
      cfg = config.programs.kitty;
    in
    {
      config = lib.mkIf cfg.enable {
        programs.kitty = {
          themeFile = "Monokai";
          extraConfig = ''
            font_family Sarasa Term Slab SC

            background_opacity 0.75
            background_blur 128

            cursor_shape underline

            window_padding_width 8
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

        programs.fuzzel.settings.main.terminal = "${lib.getExe cfg.package} {cmd}";

        home.packages = [
          (pkgs.writeShellScriptBin "dicat" (builtins.readFile ./dicat.src))
        ];
      };
    };
}

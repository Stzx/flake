{
  home =
    { lib, config, ... }:

    let
      inherit (lib) types mkOption;

      cfg = config.programs.wezterm;
    in
    {
      options.programs.wezterm = {
        userConfig = mkOption {
          type = types.lines;
          default = "";
        };
      };

      config = lib.mkIf config.programs.wezterm.enable {
        programs.wezterm = {
          extraConfig = ''
            local act = wezterm.action

            local cfg = wezterm.config_builder()

            cfg.front_end = "WebGpu"
            cfg.unicode_version = 14

            cfg.default_cwd = wezterm.home_dir
            cfg.default_prog = { '${lib.getExe config.programs.zsh.package}' }
            cfg.default_cursor_style = 'BlinkingUnderline'
            cfg.color_scheme = 'Monokai Remastered'
            cfg.font_size = 11
            cfg.font = wezterm.font_with_fallback {
                'Sarasa Term Slab SC',
                'Sarasa Term Slab TC',
                'Sarasa Term Slab J',
                'Sarasa Term Slab K',
            }

            cfg.show_new_tab_button_in_tab_bar = false
            cfg.show_close_tab_button_in_tabs = false
            cfg.show_tab_index_in_tab_bar = false
            cfg.tab_bar_at_bottom = true
            cfg.window_background_opacity = 0.85

            cfg.check_for_updates = false

            cfg.keys = {
              { key = 'd', mods = 'ALT', action = act.SendString 'cd ..\n', },
            }

            ${cfg.userConfig}
            return cfg
          '';
        };
      };
    };
}

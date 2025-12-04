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

      config = lib.mkIf cfg.enable {
        programs.wezterm = {
          extraConfig = ''
            local act = wezterm.action

            local opt = wezterm.config_builder()

            opt.front_end = "WebGpu"
            opt.unicode_version = 14
            opt.freetype_interpreter_version = 40

            opt.default_cwd = wezterm.home_dir
            opt.default_prog = { '${lib.getExe config.programs.zsh.package}' }
            opt.default_cursor_style = 'BlinkingUnderline'

            opt.color_scheme = 'Monokai Remastered'

            opt.font_size = 11
            opt.font = wezterm.font_with_fallback {
                'Sarasa Term Slab SC',
                'Sarasa Term Slab TC',
                'Sarasa Term Slab J',
                'Sarasa Term Slab K',
                'Symbols Nerd Font Mono',
            }

            -- opt.show_close_tab_button_in_tabs = false
            -- opt.show_new_tab_button_in_tab_bar = false
            opt.show_tab_index_in_tab_bar = false

            opt.tab_bar_at_bottom = true
            opt.enable_scroll_bar = true -- not work ???

            opt.window_background_opacity = 0.90
            opt.kde_window_background_blur = true

            -- opt.hyperlink_rules = wezterm.default_hyperlink_rules()

            -- table.insert(opt.hyperlink_rules, {
            --   regex = [[]],
            --   format = '\',
            -- })

            opt.check_for_updates = false

            ${cfg.userConfig}

            opt.keys = {
              { key = 'e', mods = 'ALT', action = act.SendString 'cd -\n', },
              { key = 'd', mods = 'ALT', action = act.SendString 'cd ..\n', },
            }

            return opt
          '';
        };

        programs.fuzzel.settings.main.terminal = "${lib.getExe cfg.package} start -- {cmd}";
      };
    };
}

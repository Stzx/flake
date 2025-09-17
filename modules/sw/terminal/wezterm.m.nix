{
  home =
    { lib, config, ... }:
    {
      config = lib.mkIf config.programs.wezterm.enable {
        programs.wezterm = {
          extraConfig = ''
            local cfg = wezterm.config_builder()

            cfg.front_end = "WebGpu"

            cfg.default_prog = { '${lib.getExe config.programs.zsh.package}' }
            cfg.color_scheme = 'Monokai Remastered'
            cfg.font_size = 11
            cfg.font = wezterm.font_with_fallback {
                'Sarasa Term Slab SC',
                'Sarasa Term Slab TC',
                'Sarasa Term Slab J',
                'Sarasa Term Slab K',
            }

            cfg.show_tab_index_in_tab_bar = false
            cfg.window_background_opacity = 0.85

            cfg.check_for_updates = false

            return cfg
          '';
        };
      };
    };
}

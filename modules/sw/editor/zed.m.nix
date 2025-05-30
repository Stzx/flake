{
  home =
    { lib, config, ... }:

    let
      cfg = config.programs.zed-editor;
    in
    {
      config = lib.mkIf cfg.enable {
        programs.zed-editor.userSettings = {
          ui_font_size = 16;
          ui_font_family = "Comic Mono";
          ui_font_fallbacks = [ "Symbols Nerd Font Mono" ];

          buffer_font_size = 14;
          buffer_font_features.calt = true;
          buffer_font_family = "Monaspace Neon Frozen";
          buffer_font_fallbacks = [
            "Sarasa Mono SC"
            "Sarasa Mono TC"
            "Sarasa Mono HC"
            "Sarasa Mono J"
            "Sarasa Mono K"
            "Symbols Nerd Font Mono"
          ];
          theme = {
            mode = "system";
            light = "Monokai Charcoal (green)";
            dark = "Monokai Charcoal (purple)";
          };
          "experimental.theme_overrides" = {
            syntax = rec {
              comment.font_style = "italic";
              "comment.doc" = comment;
            };
          };

          load_direnv = "shell_hook";

          vim_mode = true;

          inlay_hints.enabled = true;
          preview_tabs.enable_preview_from_code_navigation = true;
          minimap.show = "auto";

          terminal = {
            dock = "bottom";
            font_size = 14;
            font_family = "Sarasa Term Slab SC";
            font_fallbacks = [
              "Sarasa Term Slab TC"
              "Sarasa Term Slab HC"
              "Sarasa Term Slab J"
              "Sarasa Term Slab K"
              "Symbols Nerd Font Mono"
            ];
          };

          language_models = {
            openai = {
              version = "1";
              api_url = "https://api.deepseek.com";
              low_speed_timeout_in_seconds = 600;
              available_models = [
                {
                  name = "deepseek-chat";
                  max_tokens = 4000;
                }
              ];
            };
          };

          agent = {
            default_model = {
              provider = "openai";
              model = "deepseek-chat";
            };
            version = "2";
          };

          edit_predictions = {
            mode = "subtle";
          };

          cursor_shape = "underline";
          show_whitespaces = "all";
          autosave = "on_focus_change";

          file_types = {
            "Shell Script" = [
              "sh"
              "source"
              "src"
            ];
          };
          file_scan_exclusions = [
            "**/.git"
            "**/.svn"
            "**/.direnv"
            "**/.hg"
            "**/.jj"
            "**/.DS_Store"
            "**/.classpath"
            "**/.settings"
            "**/CVS"
            "**/Thumbs.db"
          ];

          languages = {
            Nix = {
              language_servers = [
                "nil"
                "!nixd"
              ];
            };
          };

          auto_install_extensions = {
            html = false; # FIXME: https://github.com/zed-industries/zed/issues/16703

            lua = true;
            dart = true;
            nix = true;
            latex = true;

            make = true;
            toml = true;
            xml = true;
            proto = true;

            vscode-monokai-charcoal = true;
          };

          features.copilot = false;
          telemetry = {
            diagnostics = false;
            metrics = false;
          };
          auto_update = false;
        };
      };
    };
}

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
          ui_font_family = "Monaspace Radon Frozen";
          ui_font_fallbacks = [ "Symbols Nerd Font Mono" ];

          buffer_font_size = 14;
          buffer_font_family = "Sarasa Mono Slab SC";
          buffer_font_fallbacks = [
            "Sarasa Mono Slab TC"
            "Sarasa Mono Slab J"
            "Sarasa Mono Slab K"
            "Symbols Nerd Font Mono"
          ];

          theme = {
            mode = "system";
            light = "Monokai Charcoal (green)";
            dark = "Monokai Charcoal (purple)";
          };
          icon_theme = "Material Icon Theme";
          "experimental.theme_overrides" = {
            syntax = {
              "comment".font_style = "italic";
              "comment.doc".font_style = "italic";
            };

            # transparent / blur - base `Monokai Charcoal`
            "background" = "#4c464290";
            "background.appearance" = "blurred";

            "editor.background" = "#00000070";
            "editor.gutter.background" = "#00000070";

            "panel.background" = "#00000070";
            "tab.active_background" = "#000000AF";
            "tab.inactive_background" = "#00000000";

            "tab_bar.background" = "#00000070";
            "title_bar.background" = "#00000070";
            "status_bar.background" = "#00000070";

            "toolbar.background" = "#000000AF";
            "scrollbar.track.background" = "#000000AF";
            "terminal.background" = "#00000070";
          };

          vim_mode = true;
          relative_line_numbers = true;

          inlay_hints.enabled = true;
          minimap.show = "auto";
          preview_tabs.enable_preview_from_code_navigation = true;

          terminal = {
            dock = "bottom";
            font_size = 14;
            font_family = "Sarasa Term Slab SC";
            font_fallbacks = [
              "Sarasa Term Slab TC"
              "Sarasa Term Slab J"
              "Sarasa Term Slab K"
              "Symbols Nerd Font Mono"
            ];
            toolbar = {
              breadcrumbs = false;
            };
            cursor_shape = "underline";
            copy_on_select = true;
          };

          edit_predictions.mode = "subtle";

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
              format_on_save = "off"; # FIXME: https://github.com/numtide/treefmt/issues/596
            };
          };

          auto_install_extensions = {
            html = false; # FIXME: https://github.com/zed-industries/zed/issues/16703

            java = true;
            lua = true;
            dart = true;
            nix = true;
            latex = true;

            make = true;
            toml = true;
            ini = true;
            xml = true;
            qml = true;
            proto = true;
            dockerfile = true;
            assembly = true;

            material-icon-theme = true;
            vscode-monokai-charcoal = true;
          };

          load_direnv = "shell_hook";

          disable_ai = true;

          telemetry = {
            diagnostics = false;
            metrics = false;
          };
          auto_update = false;
        };
      };
    };
}

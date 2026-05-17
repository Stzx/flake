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
          ui_font_family = "Monaspace Radon Var";
          ui_font_fallbacks = [ "Symbols Nerd Font Mono" ];

          buffer_font_size = 15;
          buffer_font_family = "Sarasa Mono SC";
          buffer_font_fallbacks = [
            "Sarasa Mono TC"
            "Sarasa Mono J"
            "Sarasa Mono K"
            "Symbols Nerd Font Mono"
          ];

          # Static
          "theme" = "Monokai Charcoal (purple)";
          # Dynamic
          # theme = {
          #   mode = "system";
          #   light = "Monokai Charcoal (green)";
          #   dark = "Monokai Charcoal (purple)";
          # };

          icon_theme = "Material Icon Theme";
          "experimental.theme_overrides" = {
            syntax = {
              "comment".font_style = "italic";
              "comment.doc".font_style = "italic";
            };

            # transparent / blur - base `Monokai Charcoal`
            "background" = "#000000CC";
            "background.appearance" = "blurred";

            "element.background" = "#0000007F";
            "surface.background" = "#0000007F";
            # "elevated_surface.background"= "#000000FC";

            "editor.background" = "#00000000";
            "editor.gutter.background" = "#00000000";
            "editor.indent_guide_active" = "#AE81FF7F";
            # "editor.invisible" = null;

            "panel.background" = "#00000000";
            "panel.indent_guide_active" = "#A6E22E7F";
            # "panel.overlay_background"= "#000000FC";

            "terminal.background" = "#00000000";

            # "tab.active_background" = "#00000000";
            # "tab.inactive_background" = "#000000FF";

            "tab_bar.background" = "#00000000";
            "title_bar.background" = "#000000CC";
            "status_bar.background" = "#000000CC";

            # "toolbar.background" = "#00000000";
            "scrollbar.track.background" = "#000000BF";
          };

          vim_mode = true;
          relative_line_numbers = "enabled";

          inlay_hints.enabled = true;
          minimap.show = "auto";

          terminal = {
            dock = "bottom";
            font_size = 15;
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
              "*.sh"
              "*.source"
              "*.src"
              ".envrc"
            ];
            "XML" = [
              "*.xml"
              "**/fontconfig/**/*.conf"
            ];
            "Python" = [
              "*.py"
              "*.vpy"
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
                "nixd"
                "!nil"
              ];
              format_on_save = "off"; # FIXME: https://github.com/numtide/treefmt/issues/596
            };
          };

          auto_install_extensions = {
            html = false; # FIXME: https://github.com/zed-industries/zed/issues/16703

            kotlin = true;
            java = true;
            lua = true;
            dart = true;
            nix = true;
            latex = true;

            make = true;
            toml = true;
            ini = true;
            xml = true;
            kdl = true;
            qml = true;
            proto = true;
            dockerfile = true;
            assembly = true;

            material-icon-theme = true;
            vscode-monokai-charcoal = true;
          };

          # disable_ai = true;

          telemetry = {
            diagnostics = false;
            metrics = false;
          };
          auto_update = false;
        };
      };
    };
}

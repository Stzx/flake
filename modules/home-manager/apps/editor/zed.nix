{
  programs.zed-editor = {
    extensions = [
      "latex"

      "html"
      "lua"
      "nix"

      "xml"
      "toml"

      "vscode-monokai-charcoal"
    ];
    userSettings = {
      telemetry = {
        diagnostics = false;
        metrics = false;
      };
      features.copilot = false;
      ui_font_size = 16;
      ui_font_family = "ComicShannsMono Nerd Font";
      ui_font_fallbacks = [ "Sarasa Fixed SC" ];
      buffer_font_size = 14;
      buffer_font_family = "Sarasa Mono SC";
      buffer_font_fallbacks = [ "Symbols Nerd Font Mono" ];
      theme = {
        mode = "system";
        light = "One Light";
        dark = "Monokai Charcoal (purple)";
      };
      vim_mode = true;
      inlay_hints = {
        enabled = true;
      };
      terminal = {
        dock = "right";
        shell = {
          program = "zsh";
        };
        font_size = 14;
        font_family = "Sarasa Term Slab SC";
        font_fallbacks = [ "Symbols Nerd Font Mono" ];
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
      assistant = {
        default_model = {
          provider = "openai";
          model = "deepseek-chat";
        };
        version = "2";
      };
      load_direnv = "shell_hook";
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
        "**/CVS"
        "**/.DS_Store"
        "**/.classpath"
        "**/.settings"
        "**/Thumbs.db"
      ];
      languages = {
        Nix = {
          language_servers = [
            "nil"
            "!nixd"
          ];
          formatter = {
            external = {
              command = "nixfmt";
            };
          };
        };
      };
    };
  };
}

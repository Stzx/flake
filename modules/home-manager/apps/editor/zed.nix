{
  programs.zed-editor.userSettings = {
    ui_font_size = 16;
    ui_font_family = "ComicShannsMono Nerd Font";
    ui_font_fallbacks = [ "Symbols Nerd Font Mono" ];
    buffer_font_size = 14;
    buffer_font_family = "Sarasa Mono SC";
    buffer_font_fallbacks = [
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

    load_direnv = "shell_hook";

    vim_mode = true;

    inlay_hints.enabled = true;

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
}

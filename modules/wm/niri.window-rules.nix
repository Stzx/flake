[
  {
    geometry-corner-radius = {
      top-left = 3.0;
      top-right = 3.0;
      bottom-left = 3.0;
      bottom-right = 3.0;
    };
    clip-to-geometry = true;
    draw-border-with-background = false;
  }

  # only startup
  {
    matches = [
      { app-id = "^(?-x:org\\.wezfurlong\\.wezterm)$"; at-startup = true; }
    ];

    open-on-workspace = "terminal";
    open-maximized = true;
  }
  {
    matches = [
      { app-id = "^(?-x:kitty|firefox)$"; at-startup = true; }
    ];

    open-on-workspace = "sea";
    open-maximized = true;
  }

  # non-floating window rules
  {
    matches = [
      { app-id = "^spotify$"; }
    ];

    open-on-workspace = "sea";
  }
  {
    matches = [
      { app-id = "^org\\.telegram\\.desktop$"; }
      { app-id = "^thunderbird$"; }
      { app-id = "^calibre-gui$"; }
    ];
    excludes = [
      { app-id = "^org\\.telegram\\.desktop$"; title = "^Media viewer$"; }
      { app-id = "^calibre-gui$";            title = "^calibre - Preferences$"; }
    ];

    open-on-workspace = "chat";

    default-column-width.proportion = 0.5;
  }
  {
    matches = [
      { app-id = "^org\\.(?-x:qbittorrent|prismlauncher)\\.(?-x:qBittorrent|PrismLauncher)$"; }
      { app-id = "^steam$"; }
    ];
    excludes = [
      { app-id = "^org\\.qbittorrent\\.qBittorrent$"; title = "^(?-x:Preferences|Rename|Renaming)$"; }
    ];

    open-on-workspace = "run";
    open-maximized = true;

    default-column-display = "tabbed";
  }
  {
    matches = [
      { app-id = "^dev\\.zed\\.Zed$"; }
    ];

    open-on-workspace = "anvil";
    open-maximized = true;
  }
  {
    matches = [
      { app-id = "^org\\.keepassxc\\.KeePassXC$"; }
      { app-id = "^com\\.obsproject\\.Studio$"; }
      { app-id = "^veracrypt$"; }
    ];

    open-on-workspace = "magic";

    block-out-from = "screen-capture";
  }
  {
    matches = [
      { app-id = "^mpv$"; }
      { app-id = "\\.exe$"; }
      { title = "Minecraft\\* [\\w\\.]{3,}"; }
    ];

    variable-refresh-rate = true;
    open-floating = false;
  }

  # floating window rules
  {
    matches = [
      { app-id = "^thunderbird$"; title = "^Password Required"; }
      { app-id = "cheatengine-x86_64.exe"; }
    ];

    open-fullscreen = false;
    open-floating = true;
  }
  {
    matches = [
      { app-id = "^org\\.(?-x:qbittorrent|telegram)\\.(?-x:qBittorrent|desktop)$"; title = "^(?-x:Preferences|Rename|Renaming|Media viewer)$"; }
      { app-id = "^firefox$";     title = "^(?-x:Picture-in-Picture|Library|About Mozilla Firefox|画中画|我的足迹|关于 Mozilla Firefox)$"; }
      { app-id = "^veracrypt$";   title = "^Select (?-x:a|Keyfile)"; }
      { app-id = "^calibre-gui$"; title = "^calibre - Preferences$"; }
    ];

    open-fullscreen = false;
    open-floating = true;

    default-column-width.fixed = 1280;
    default-window-height.proportion = 0.75;
  }
]

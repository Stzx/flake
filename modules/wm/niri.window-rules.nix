[
  {
    matches = [ { is-focused = true; } ];
    clip-to-geometry = true;
  }

  # only startup
  {
    matches = [
      { app-id = "^kitty$"; at-startup = true; }
    ];

    open-on-workspace = "terminal";

    default-column-width.proportion = 0.75;
  }
  {
    matches = [
      { app-id = "^firefox$"; at-startup = true; }
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
      { app-id = "^org\.telegram\.desktop$"; }
      { app-id = "^thunderbird$"; }
      { app-id = "^calibre-gui$"; }
    ];
    excludes = [
      { app-id = "^org\.telegram\.desktop$";title = "^Media viewer$"; }
      { app-id = "^thunderbird$"; title = "^(?-x:Password Required|Enter credentials for)"; }
      { app-id = "^calibre-gui$"; title = "^calibre - Preferences$"; }
    ];

    open-on-workspace = "chat";

    default-column-width.proportion = 0.5;
  }
  {
    matches = [
      { app-id = "^org\.qbittorrent\.qBittorrent$"; }
      { app-id = "^org\.prismlauncher\.PrismLauncher$"; }
      { app-id = "^steam$"; }
    ];
    excludes = [
      { app-id = "^org\.qbittorrent\.qBittorrent$"; title = "^Preferences$"; }
    ];

    open-on-workspace = "run";

    default-column-display = "tabbed";
  }
  {
    matches = [ { app-id = "^dev\.zed\.Zed$"; } ];

    open-on-workspace = "anvil";
    open-maximized = true;
  }
  {
    matches = [
      { app-id = "^org\.keepassxc\.KeePassXC$"; }
      { app-id = "^com\.obsproject\.Studio$"; }
      { app-id = "^veracrypt$"; }
    ];

    open-on-workspace = "magic";

    block-out-from = "screen-capture";
  }

  # floating window rules
  {
    matches = [
      { app-id = "^org\.qbittorrent\.qBittorrent$"; title = "^(Preferences|Rename|Renaming)$"; }
      { app-id = "^org\.telegram\.desktop$"; title = "^Media viewer$"; }
      { app-id = "^firefox$"; title = "^(?-x:Picture-in-Picture|Library|About Mozilla Firefox)$"; }
      { app-id = "^calibre-gui$"; title = "^calibre - Preferences$"; }
    ];

    open-fullscreen = false;
    open-floating = true;

    default-column-width.proportion = 0.5;
    default-window-height.proportion = 0.75;
  }
  {
    matches = [
      { app-id = "^thunderbird$"; title = "^(?-x:Password Required|Enter credentials for)"; }
      { app-id = "^veracrypt$"; }
    ];

    open-floating = true;

    default-floating-position = { x = 6; y = 6; relative-to = "bottom-right"; };
  }
]

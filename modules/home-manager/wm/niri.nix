{ lib, config, ... }:

let
  inherit (lib) mkIf singleton isNiri;
in
mkIf isNiri {
  programs.niri = {
    enable = true;
    settings = {
      spawn-at-startup = [
        { command = [ "kitty" ]; }
        { command = [ "firefox" ]; }
        { command = [ "thunderbird" ]; }
      ];
      prefer-no-csd = true;
      input.touchpad.enable = false;
      outputs = {
        "DP-1".variable-refresh-rate = "on-demand";
        "DP-2".transform.rotation = 90;
      };
      layout = {
        gaps = 6;
        always-center-single-column = true;
        focus-ring = {
          width = 2;
          active = {
            gradient = {
              angle = 45;
              in' = "oklch longer hue";
              from = "#C2185B";
              to = "#689F38";
            };
          };
        };
      };
      workspaces = {
        "1".name = "terminal";
        "2".name = "sea";
        "3".name = "chat";
        "4".name = "run";
        "5".name = "anvil";
        "6".name = "magic";
      };
      window-rules = [
        {
          matches = singleton { is-focused = true; };
          clip-to-geometry = true;
        }
        {
          matches = singleton {
            app-id = "kitty";
            at-startup = true;
          };
          open-on-workspace = "terminal";
          default-column-width.proportion = 0.75;
        }
        {
          matches = singleton {
            app-id = "firefox";
            at-startup = true;
          };
          open-on-workspace = "sea";
          open-maximized = true;
        }
        {
          matches = [
            { app-id = "org.telegram.desktop"; }
            { app-id = "thunderbird"; }
          ];
          excludes = singleton { title = "Media viewer"; };
          open-on-workspace = "chat";
          default-column-width.proportion = 0.5;
        }
        {
          matches = singleton {
            app-id = "org.telegram.desktop";
            title = "Media viewer";
          };
          open-fullscreen = false;
          open-floating = true;

          default-column-width.proportion = 0.75;
          default-window-height.proportion = 0.75;
        }
        {
          matches = singleton { app-id = "org.qbittorrent.qBittorrent"; };
          open-on-workspace = "run";

          default-column-width.proportion = 0.75;
        }
        {
          matches = singleton { app-id = "dev.zed.Zed"; };
          open-on-workspace = "anvil";
          open-maximized = true;
        }
        {
          matches = [
            { app-id = "veracrypt"; }
            { app-id = "org.keepassxc.KeePassXC"; }
          ];
          open-on-workspace = "magic";
          block-out-from = "screen-capture";
        }
      ];
      binds = with config.lib.niri.actions; {
        "Mod+1".action = focus-workspace "terminal";
        "Mod+2".action = focus-workspace "sea";
        "Mod+3".action = focus-workspace "chat";
        "Mod+8".action = focus-workspace "run";
        "Mod+9".action = focus-workspace "anvil";
        "Mod+0".action = focus-workspace "magic";

        "Mod+Shift+1".action = move-column-to-workspace "terminal";
        "Mod+Shift+2".action = move-column-to-workspace "sea";
        "Mod+Shift+3".action = move-column-to-workspace "chat";
        "Mod+Shift+8".action = move-column-to-workspace "run";
        "Mod+Shift+9".action = move-column-to-workspace "anvil";
        "Mod+Shift+0".action = move-column-to-workspace "magic";

        "Mod+H".action = focus-column-left;
        "Mod+L".action = focus-column-right;

        "Mod+Home".action = focus-column-first;
        "Mod+End".action = focus-column-last;

        "Mod+Shift+H".action = move-column-left;
        "Mod+Shift+L".action = move-column-right;

        "Mod+Shift+Home".action = move-column-to-first;
        "Mod+Shift+End".action = move-column-to-last;

        "Mod+Prior".action = focus-workspace-up;
        "Mod+Next".action = focus-workspace-down;

        "Mod+Up".action = move-column-to-monitor-up;
        "Mod+Down".action = move-column-to-monitor-down;
        "Mod+Left".action = move-column-to-monitor-left;
        "Mod+Right".action = move-column-to-monitor-right;

        "Mod+Q".action = spawn "fuzzel";
        "Mod+T".action = spawn "kitty";
        "Mod+B".action = spawn "firefox";

        "Mod+P".action = power-off-monitors;
        "Mod+Slash".action = show-hotkey-overlay;

        "Mod+W".action = switch-preset-column-width;
        "Mod+F".action = fullscreen-window;
        "Mod+M".action = maximize-column;
        "Mod+C".action = center-column;
        "Mod+X".action = close-window;

        "Mod+S".action = screenshot-window;
        "Mod+Shift+S".action = screenshot-screen;

        "Mod+Shift+Q".action = quit;

        "XF86AudioMute".action = spawn "wpctl" "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle";
        "XF86AudioLowerVolume".action = spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "1%-";
        "XF86AudioRaiseVolume".action = spawn "wpctl" "set-volume" "-l" "1.0" "@DEFAULT_AUDIO_SINK@" "1%+";

        "XF86AudioPrev".action = spawn "playerctl" "previous";
        "XF86AudioPlay".action = spawn "playerctl" "play-pause";
        "XF86AudioNext".action = spawn "playerctl" "next";
      };
    };
  };

  programs.waybar = {
    left = [
      "clock"
      "niri/window"
    ];
    center = [
      "niri/workspaces"
    ];
    right = [
      "tray"
      "load"
      "wireplumber"
      "network"
      "group/power"
    ];
  };
}

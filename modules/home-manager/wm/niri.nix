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
        { command = [ "telegram-desktop" ]; }
      ];
      prefer-no-csd = true;
      input.touchpad.enable = false;
      outputs."DP-1".variable-refresh-rate = "on-demand";
      layout = {
        gaps = 6;
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
        "5".name = "dark";
        "6".name = "magic";
      };
      window-rules = [
        {
          matches = singleton { is-focused = true; };
          clip-to-geometry = true;
        }
        {
          matches = singleton { app-id = "kitty"; };
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
          open-on-workspace = "chat";
        }
        {
          matches = [ { app-id = "org.keepassxc.KeePassXC"; } ];
          open-on-workspace = "magic";
          block-out-from = "screen-capture";
        }
      ];
      binds = with config.lib.niri.actions; {
        "Mod+1".action = focus-workspace "terminal";
        "Mod+2".action = focus-workspace "sea";
        "Mod+3".action = focus-workspace "chat";
        "Mod+A".action = focus-workspace "run";
        "Mod+S".action = focus-workspace "dark";
        "Mod+D".action = focus-workspace "magic";

        "Mod+Shift+1".action = move-column-to-workspace "terminal";
        "Mod+Shift+2".action = move-column-to-workspace "sea";
        "Mod+Shift+3".action = move-column-to-workspace "chat";
        "Mod+Shift+A".action = move-column-to-workspace "run";
        "Mod+Shift+S".action = move-column-to-workspace "dark";
        "Mod+Shift+D".action = move-column-to-workspace "magic";

        "Mod+H".action = focus-column-left;
        "Mod+Left".action = focus-column-left;

        "Mod+L".action = focus-column-right;
        "Mod+Right".action = focus-column-right;

        "Mod+K".action = focus-window-up;
        "Mod+Up".action = focus-window-up;

        "Mod+J".action = focus-window-down;
        "Mod+Down".action = focus-window-down;

        "Mod+Home".action = focus-column-first;
        "Mod+End".action = focus-column-last;

        "Mod+Ctrl+H".action = move-column-left;
        "Mod+Ctrl+Left".action = move-column-left;

        "Mod+Ctrl+L".action = move-column-right;
        "Mod+Ctrl+Right".action = move-column-right;

        "Mod+Ctrl+Home".action = move-column-to-first;
        "Mod+Ctrl+End".action = move-column-to-last;

        "Mod+Shift+M".action = maximize-column;
        "Mod+Shift+F".action = fullscreen-window;
        "Mod+Shift+C".action = center-column;
        "Mod+Shift+X".action = close-window;

        "Mod+Shift+Q".action = quit;
        "Mod+Shift+P".action = power-off-monitors;
        "Mod+Shift+Slash".action = show-hotkey-overlay;

        "Mod+Q".action = spawn "tofi";
        "Mod+T".action = spawn "kitty";

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

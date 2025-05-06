{ lib, config, ... }:

let
  inherit (lib) mkIf singleton isNiri;
in
(mkIf isNiri {
  programs.niri.settings = {
    spawn-at-startup = [
      { command = singleton "kitty"; }
      { command = singleton "firefox"; }
      { command = singleton "thunderbird"; }
    ];
    prefer-no-csd = true;
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
    screenshot-path = "~/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png";
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

      # only startup
      {
        matches = singleton {
          app-id = "firefox";
          at-startup = true;
        };

        open-on-workspace = "sea";
        open-maximized = true;
      }
      {
        matches = singleton {
          app-id = "kitty";
          at-startup = true;
        };

        open-on-workspace = "terminal";
      }

      # non-floating window rules
      {
        matches = [
          { app-id = "org.telegram.desktop"; }
          { app-id = "thunderbird"; }
        ];
        excludes = [
          {
            app-id = "org.telegram.desktop";
            title = "Media viewer";
          }
          {
            app-id = "thunderbird";
            title = "^(?-x:Password Required|Enter credentials for)";
          }
        ];

        open-on-workspace = "chat";

        default-column-width.proportion = 0.5;
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
          { app-id = "com.obsproject.Studio"; }
        ];

        open-on-workspace = "magic";

        block-out-from = "screen-capture";
      }

      # floating window rules
      {
        matches = singleton {
          app-id = "thunderbird";
          title = "^(?-x:Password Required|Enter credentials for)";
        };

        open-floating = true;
        open-on-workspace = "chat";
      }
      {
        matches = [
          {
            app-id = "org.telegram.desktop";
            title = "Media viewer";
          }
          {
            app-id = "firefox";
            title = "^(?-x:Picture-in-Picture|Library|About Mozilla Firefox)$";
          }
        ];

        open-fullscreen = false;
        open-floating = true;

        default-column-width.proportion = 0.5;
        default-window-height.proportion = 0.75;
      }
      {
        matches = [
          { app-id = "veracrypt"; }
          {
            app-id = "thunderbird";
            title = "^Password Required";
          }
        ];

        default-floating-position = {
          x = 6;
          y = 6;
          relative-to = "bottom-right";
        };
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

      "Mod+P".action = power-off-monitors;
      "Mod+Slash".action = show-hotkey-overlay;

      "Mod+W".action = switch-preset-column-width;
      "Mod+E".action = expand-column-to-available-width;

      "Mod+F".action = fullscreen-window;
      "Mod+M".action = maximize-column;
      "Mod+C".action = center-column;
      "Mod+X".action = close-window;

      "Mod+S".action = screenshot;
      "Mod+Shift+S".action.screenshot-screen = [ ]; # FIXME: niri-flake bug
      "Mod+Print".action = screenshot-window { write-to-disk = false; };

      "Mod+Shift+Q".action = quit;

      "XF86AudioMute".action = spawn "wpctl" "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle";
      "XF86AudioLowerVolume".action = spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "1%-";
      "XF86AudioRaiseVolume".action = spawn "wpctl" "set-volume" "-l" "1.0" "@DEFAULT_AUDIO_SINK@" "1%+";

      "XF86AudioPrev".action = spawn "playerctl" "previous";
      "XF86AudioPlay".action = spawn "playerctl" "play-pause";
      "XF86AudioNext".action = spawn "playerctl" "next";
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
      "wlr/taskbar"
      "pulseaudio"
      "network"
      "load"
      "tray"
      "group/power"
    ];
    extraSettings = {
      "niri/workspaces" = {
        format = "{icon}";
        format-icons = {
          default = "󰋦"; # nf-md-human

          terminal = "󱆃"; # nf-md-bash
          chat = "󱧎"; # nf-md-message_text_fast
          sea = "󱝆"; # nf-md-surfing
          run = "󰜎"; # nf-md-run
          anvil = "󰢛"; # nf-md-anvil
          magic = "󰄛"; # nf-md-cat
        };
      };

      "niri/window" = {
        format = "{title:.25}";
        icon = true;
      };
    };
  };
})

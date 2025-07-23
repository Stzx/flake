{
  sys =
    {
      lib,
      wmCfg,
      ...
    }:
    {
      config = lib.mkIf wmCfg.isNiri {
        programs.niri = {
          enable = true;
        };
      };
    };

  home =
    {
      lib,
      config,
      sysCfg,
      wmCfg,
      ...
    }:

    let
      inherit (lib) mkAfter;
    in
    {
      config = lib.mkIf (wmCfg.isNiri) {
        programs.niri.settings = {
          spawn-at-startup = [
            { command = singleton "kitty"; }
            { command = singleton "firefox"; }
            { command = singleton "thunderbird"; }
          ];
          prefer-no-csd = true;
          layout = {
            gaps = 5;
            always-center-single-column = true;
            tab-indicator = {
              width = 3;
              position = "right";
              place-within-column = true;
            };
            focus-ring = {
              width = 3;
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
          window-rules = import ./niri.window-rules.nix;
          binds = with config.lib.niri.actions; {
            "Mod+1".action = focus-workspace "terminal";
            "Mod+2".action = focus-workspace "sea";
            "Mod+3".action = focus-workspace "chat";
            "Mod+8".action = focus-workspace "run";
            "Mod+9".action = focus-workspace "anvil";
            "Mod+0".action = focus-workspace "magic";

            "Mod+Prior".action = focus-workspace-up;
            "Mod+Shift+WheelScrollUp".action = focus-workspace-up;
            "Mod+Next".action = focus-workspace-down;
            "Mod+Shift+WheelScrollDown".action = focus-workspace-down;

            # FIXME: https://github.com/sodiboo/niri-flake/issues/1018
            "Mod+Shift+1".action.move-column-to-workspace = "terminal";
            "Mod+Shift+2".action.move-column-to-workspace = "sea";
            "Mod+Shift+3".action.move-column-to-workspace = "chat";
            "Mod+Shift+8".action.move-column-to-workspace = "run";
            "Mod+Shift+9".action.move-column-to-workspace = "anvil";
            "Mod+Shift+0".action.move-column-to-workspace = "magic";

            "Mod+Ctrl+Left".action = move-workspace-to-monitor-left;
            "Mod+Ctrl+Down".action = move-workspace-to-monitor-down;
            "Mod+Ctrl+Up".action = move-workspace-to-monitor-up;
            "Mod+Ctrl+Right".action = move-workspace-to-monitor-right;

            "Mod+Home".action = focus-column-first;
            "Mod+H".action = focus-column-left;
            "Mod+WheelScrollUp".action = focus-column-left;
            "Mod+J".action = focus-window-down;
            "Mod+K".action = focus-window-up;
            "Mod+L".action = focus-column-right;
            "Mod+WheelScrollDown".action = focus-column-right;
            "Mod+End".action = focus-column-last;

            "Mod+Tab".action = focus-window-down-or-column-right;
            "Mod+Shift+Tab".action = focus-window-up-or-column-left;

            "Mod+Shift+Home".action = move-column-to-first;
            "Mod+Shift+H".action = move-column-left;
            "Mod+Shift+J".action = move-window-down;
            "Mod+Shift+K".action = move-window-up;
            "Mod+Shift+L".action = move-column-right;
            "Mod+Shift+End".action = move-column-to-last;

            "Mod+Left".action = focus-monitor-left;
            "Mod+Down".action = focus-monitor-down;
            "Mod+Up".action = focus-monitor-up;
            "Mod+Right".action = focus-monitor-right;

            "Mod+Shift+Left".action = move-column-to-monitor-left;
            "Mod+Shift+Down".action = move-column-to-monitor-down;
            "Mod+Shift+Up".action = move-column-to-monitor-up;
            "Mod+Shift+Right".action = move-column-to-monitor-right;

            "Mod+Q".action = spawn "fuzzel";
            "Mod+T".action = spawn "kitty";

            "Mod+W".action = switch-preset-column-width;
            "Mod+bracketleft".action = switch-preset-window-width;
            "Mod+bracketright".action = switch-preset-window-height;

            "Mod+M".action = maximize-column;
            "Mod+X".action = close-window;
            "Mod+C".action = center-column;
            "Mod+Shift+C".action = center-window;
            "Mod+Return".action = fullscreen-window;

            # Tabbed
            "Mod+I".action = consume-window-into-column;
            "Mod+Shift+I".action = expel-window-from-column;
            "Mod+Ctrl+I".action = toggle-column-tabbed-display;

            "Mod+P".action = power-off-monitors;
            "Mod+Slash".action = show-hotkey-overlay;
            "Mod+E".action = expand-column-to-available-width;
            # "Mod+Space".action = toggle-overview;
            "Mod+Ctrl+Escape".action = toggle-keyboard-shortcuts-inhibit;
            # "Mod+Ctrl+F".action = toggle-windowed-fullscreen;
            "Mod+Ctrl+F".action = toggle-window-floating;
            "Mod+Shift+Q".action = quit;

            # "Mod+D".action = set-dynamic-cast-window;
            # "Mod+Shift+D".action = clear-dynamic-cast-target;

            "Mod+S".action = screenshot;
            "Mod+Shift+S".action.screenshot-screen = [ ]; # FIXME: https://github.com/sodiboo/niri-flake/issues/1018
            "Mod+Print".action = screenshot-window { write-to-disk = false; };

            "Mod+grave".action = spawn "${pkgs.procps}/bin/pkill" "-SIGUSR1" "waybar";

            "XF86AudioMute".action = spawn "wpctl" "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle";
            "XF86AudioLowerVolume".action = spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "1%-";
            "XF86AudioRaiseVolume".action = spawn "wpctl" "set-volume" "-l" "1.0" "@DEFAULT_AUDIO_SINK@" "1%+";

            "XF86AudioPrev".action = spawn "playerctl" "previous";
            "XF86AudioPlay".action = spawn "playerctl" "play-pause";
            "XF86AudioNext".action = spawn "playerctl" "next";
          };
        };

        programs.waybar = {
          left = mkAfter [
            "clock"
            "niri/window"
          ];
          center = mkAfter [
            "niri/workspaces"
          ];
          right = mkAfter [
            "systemd-failed-units"
            "network"
            "load"
            "pulseaudio"
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

            "niri/window".icon = true;
          };
        };

        services.swayidle.timeouts = [
          {
            timeout = 180;
            command = "${sysCfg.programs.niri.package}/bin/niri msg action power-off-monitors";
          }
        ];
      };
    };
}

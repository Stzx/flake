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

      cfg = config.programs.niri;

      ds = cfg.display;

      open-on-output' =
        o: ws:
        builtins.mapAttrs (_: v: {
          name = v;
          open-on-output = o;
        }) ws;

      horizontal = {
        "3" = "chat";

        "8" = "run";
        "9" = "anvil";
        "0" = "magic";
      };
      vertical = {
        "1" = "terminal";
        "2" = "sea";
      };

      ws' = horizontal // vertical;

      workspaces = (open-on-output' ds.primary horizontal) // (open-on-output' ds.secondary vertical);
    in
    {
      options.programs.niri.display = {
        primary = lib.mkOption { type = lib.types.str; };
        secondary = lib.mkOption {
          type = lib.types.str;
          default = ds.primary;
        };
      };

      config = lib.mkIf (wmCfg.isNiri) {
        programs.niri.settings = {
          inherit workspaces;

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
          window-rules = import ./niri.window-rules.nix;
          binds = with config.lib.niri.actions; {
            "Mod+1".action = focus-workspace ws'."1";
            "Mod+2".action = focus-workspace ws'."2";
            "Mod+3".action = focus-workspace ws'."3";
            "Mod+8".action = focus-workspace ws'."8";
            "Mod+9".action = focus-workspace ws'."9";
            "Mod+0".action = focus-workspace ws'."0";

            "Mod+Prior".action = focus-workspace-up;
            "Mod+Shift+WheelScrollUp".action = focus-workspace-up;
            "Mod+Next".action = focus-workspace-down;
            "Mod+Shift+WheelScrollDown".action = focus-workspace-down;

            # FIXME: https://github.com/sodiboo/niri-flake/issues/1018
            "Mod+Shift+1".action.move-column-to-workspace = ws'."1";
            "Mod+Shift+2".action.move-column-to-workspace = ws'."2";
            "Mod+Shift+3".action.move-column-to-workspace = ws'."3";
            "Mod+Shift+8".action.move-column-to-workspace = ws'."8";
            "Mod+Shift+9".action.move-column-to-workspace = ws'."9";
            "Mod+Shift+0".action.move-column-to-workspace = ws'."0";

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

{
  sys =
    {
      pkgs,
      lib,
      config,
      ...
    }:

    let
      inherit (lib) mkIf;
    in
    {
      config = mkIf config.wm.isNiri (
        lib.mkMerge [
          { programs.niri.enable = true; }

          (mkIf config.services.flatpak.enable {
            environment.systemPackages = [ pkgs.xwayland-satellite ]; # Steam
          })
        ]
      );
    };

  home =
    {
      lib,
      config,
      sysCfg,
      ...
    }:

    let
      inherit (lib) mkOption mkAfter types;

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

      workspaces = (open-on-output' ds.primary horizontal) // (open-on-output' ds.secondary vertical);

      wsBinds = lib.foldlAttrs (
        acc: n: v:
        acc
        // {
          "Mod+${n}".action.focus-workspace = v;
          "Mod+Ctrl+${n}".action.move-column-to-workspace = v;
        }
      ) { } (horizontal // vertical);
    in
    {
      options.programs.niri.display = {
        primary = mkOption { type = types.str; };
        secondary = mkOption {
          type = types.str;
          default = ds.primary;
        };
      };

      config = lib.mkIf (sysCfg.wm.isNiri) {
        programs.niri.package = sysCfg.programs.niri.package;

        programs.niri.settings = {
          inherit workspaces;

          prefer-no-csd = true;
          screenshot-path = "~/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png";
          overview = {
            backdrop-color = "#808080";
            workspace-shadow.enable = false;
          };
          layout = {
            gaps = 4;
            default-column-width = { };
            always-center-single-column = true;
            empty-workspace-above-first = true;
            background-color = "transparent";
            tab-indicator = {
              width = 4;
              position = "left";
              place-within-column = true;
              active.color = "#FF1493";
              inactive.color = "#000000";
              urgent.color = "#F54927";
            };
            focus-ring.enable = false;
          };
          layer-rules = [
            {
              matches = [
                { namespace = "(bg|background|wallpaper)$"; }
              ];

              place-within-backdrop = true;
            }
            {
              matches = [
                { namespace = "^notifications$"; }
              ];

              block-out-from = "screencast";
            }
          ];
          window-rules = import ./niri.window-rules.nix;
          binds =
            wsBinds
            // (with config.lib.niri.actions; {
              "Mod+Prior".action = focus-workspace-up; # PAGE UP
              "Mod+Shift+WheelScrollUp".action = focus-workspace-up;
              "Mod+Next".action = focus-workspace-down; # PAGE DOWN
              "Mod+Shift+WheelScrollDown".action = focus-workspace-down;

              "Mod+Home".action = focus-column-first;
              "Mod+WheelScrollUp".action = focus-column-left;
              "Mod+H".action = focus-column-left;
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

              "Mod+Shift+KP_Left".action = move-workspace-to-monitor-left;
              "Mod+Shift+KP_Down".action = move-workspace-to-monitor-down;
              "Mod+Shift+KP_Up".action = move-workspace-to-monitor-up;
              "Mod+Shift+KP_Right".action = move-workspace-to-monitor-right;

              "Mod+E".action = expand-column-to-available-width;
              "Mod+Ctrl+W".action = toggle-windowed-fullscreen;
              "Mod+Ctrl+F".action = toggle-window-floating;

              "Mod+W".action = switch-preset-column-width;
              "Mod+bracketleft".action = switch-preset-window-width; # [
              "Mod+bracketright".action = switch-preset-window-height; # ]
              "Mod+Ctrl+bracketright".action = reset-window-height;

              "Mod+M".action = maximize-column;
              "Mod+X".action = close-window;
              "Mod+C".action = center-column;
              "Mod+Shift+C".action = center-window;
              "Mod+Ctrl+Return".action = fullscreen-window;

              "Mod+Space".action = consume-window-into-column;
              "Mod+Shift+Space".action = expel-window-from-column;
              "Mod+Ctrl+Space".action = toggle-column-tabbed-display;

              "Mod+O".action.open-overview = [ ];
              "Mod+Shift+O".action.close-overview = [ ];
              "Mod+Ctrl+O".action.toggle-overview = [ ];

              "Mod+Q".action = spawn "fuzzel";
              "Mod+T".action = spawn "kitty";

              "Mod+P".action = power-off-monitors;
              "Mod+Slash".action = show-hotkey-overlay; # /
              "Mod+Ctrl+Escape".action = toggle-keyboard-shortcuts-inhibit;
              "Mod+Shift+Q".action = quit;

              "Mod+D".action = set-dynamic-cast-window;
              "Mod+Shift+D".action = clear-dynamic-cast-target;

              "Mod+S".action = screenshot;
              "Mod+Shift+S".action.screenshot-screen = [ ]; # FIXME: https://github.com/sodiboo/niri-flake/issues/1018
              "Mod+Print".action = screenshot-window { write-to-disk = false; };

              "Mod+grave".action = spawn "pkill" "-SIGUSR1" "waybar"; # `

              "XF86AudioMute".action = spawn "wpctl" "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle";
              "XF86AudioLowerVolume".action = spawn "wpctl" "set-volume" "-l" "1.0" "@DEFAULT_AUDIO_SINK@" "1%-";
              "XF86AudioRaiseVolume".action = spawn "wpctl" "set-volume" "-l" "1.0" "@DEFAULT_AUDIO_SINK@" "1%+";

              "XF86AudioPrev".action = spawn "playerctl" "previous";
              "XF86AudioPlay".action = spawn "playerctl" "play-pause";
              "XF86AudioNext".action = spawn "playerctl" "next";
            });
        };

        programs.quickshell.enable = true;

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

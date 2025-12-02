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
          {
            programs.niri = {
              enable = true;
              useNautilus = lib.mkDefault false;
            };

            xdg.portal.config = lib.mkForce { };
          }

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
      dots,
      ...
    }:

    let
      inherit (lib)
        mkOption
        mkAfter
        types

        concatLines
        mapAttrsToList
        ;

      cfg = config.programs.niri;

      ds = cfg.display;

      open-on-output' = ds: mapAttrsToList (n: _: "workspace \"${n}\" { open-on-output \"${ds}\"; }");

      horizontal = {
        "chat" = {
          idx = "3";
          icon = "󱧎"; # nf-md-message_text_fast
        };

        "run" = {
          idx = "8";
          icon = "󰜎"; # nf-md-run
        };
        "anvil" = {
          idx = "9";
          icon = "󰢛"; # nf-md-anvil
        };
        "magic" = {
          idx = "0";
          icon = "󰄛"; # nf-md-cat
        };
      };
      vertical = {
        "terminal" = {
          idx = "1";
          icon = "󱆃"; # nf-md-bash
        };
        "sea" = {
          idx = "2";
          icon = "󱝆"; # nf-md-surfing
        };
      };

      ws = concatLines (
        (open-on-output' ds.primary horizontal) ++ (open-on-output' ds.secondary vertical)
      );

      wsBinds = concatLines (
        mapAttrsToList (n: v: ''
          Mod+${v.idx} { focus-workspace "${n}"; }
          Mod+Ctrl+${v.idx} { move-column-to-workspace "${n}"; }
        '') (horizontal // vertical)
      );

      cfgOption = mkOption {
        type = types.lines;
        default = "";
      };
    in
    {
      options.programs.niri = {
        display = {
          primary = mkOption { type = types.str; };
          secondary = mkOption {
            type = types.str;
            default = ds.primary;
          };
        };

        cursor = cfgOption;
        input = cfgOption;
        output = cfgOption;
        binds = cfgOption;
        spawn-at-startup = cfgOption;
        window-rule = cfgOption;
      };

      config = lib.mkIf (sysCfg.wm.isNiri) {
        xdg.configFile = {
          "niri" = {
            source = dots + "/niri";
            recursive = true;
          };
          "niri/config.kdl".text = ''
            prefer-no-csd

            include "overview.kdl"
            include "layout.kdl"

            ${cfg.cursor}

            include "input.kdl"
            input {
            ${cfg.input}
            }

            ${cfg.output}

            include "binds.kdl"
            binds {
                Mod+Q { spawn "fuzzel"; }
                Mod+T { spawn "ghostty" "+new-window"; }

                Mod+Grave { spawn "pkill" "-SIGUSR1" "waybar"; }

                XF86AudioMute { spawn "wpctl" "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle"; }
                XF86AudioLowerVolume { spawn "wpctl" "set-volume" "-l" "1.0" "@DEFAULT_AUDIO_SINK@" "1%-"; }
                XF86AudioRaiseVolume { spawn "wpctl" "set-volume" "-l" "1.0" "@DEFAULT_AUDIO_SINK@" "1%+"; }

                XF86AudioNext { spawn "playerctl" "next"; }
                XF86AudioPlay { spawn "playerctl" "play-pause"; }
                XF86AudioPrev { spawn "playerctl" "previous"; }

            ${wsBinds}
            }

            // xwayland-satellite { off; }

            ${ws}

            ${cfg.spawn-at-startup}

            include "rules.kdl"

            ${cfg.window-rule}

            screenshot-path "~/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png"
          '';
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
              }
              // lib.mapAttrs (_: v: v.icon) (horizontal // vertical);
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

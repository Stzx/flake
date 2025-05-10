{ lib, config, ... }:

let
  inherit (lib)
    mkDefault
    mkOption
    mkIf

    types

    isHyprland
    isNiri
    ;

  cfg = config.programs.waybar;
in
{
  options.programs.waybar = with types; {
    left = mkOption {
      type = listOf str;
      default = [ ];
    };
    center = mkOption {
      type = listOf str;
      default = [ ];
    };
    right = mkOption {
      type = listOf str;
      default = [ ];
    };
    extraSettings = mkOption {
      type = attrs;
      default = { };
    };
  };

  config = mkIf cfg.enable {
    programs.waybar = {
      systemd.enable = true;
      settings.mainBar = {
        layer = "top";
        height = 32;
        margin = "4px";
        spacing = 6;

        modules-left = cfg.left;
        modules-center = cfg.center;
        modules-right = cfg.right;

        tray = {
          icon-size = 24;
          spacing = 6;
          reverse-direction = true;
        };

        load = {
          format = "󰑮 <sub>{}</sub>"; # nf-md-run_fast
          tooltip = false;
        };

        network = {
          interval = 3;
          format-ethernet = " <sub>{bandwidthUpBits}</sub>  | 󰞉 |  <sub>{bandwidthDownBits}</sub> "; # nf-oct-upload, nf-md-web_check, nf-oct-download
          format-linked = "󱐅"; # nf-md-earth_remove
          format-disconnected = "󰇨"; # nf-md-earth_off
          tooltip = false;
        };

        keyboard-state = {
          numlock = true;
          capslock = true;
          scrolllock = true;
          format = {
            numlock = "N {icon}";
            capslock = "C {icon}";
            scrolllock = "S {icon}";
          };
          format-icons = {
            locked = "󰨀"; # nf-md-lighthouse_on
            unlocked = "󰧿"; # nf-md-lighthouse
          };
        };

        # [warning] [wireplumber]: (onMixerChanged) - Object with id xx not found
        wireplumber = {
          format = "{icon} <sub>{volume}%</sub>";
          format-icons = [
            "󰕿"
            "󰖀"
            "󰕾"
          ]; # nf-md-volume low / medium / high
          format-muted = "󰝟"; # nf-md-volume_mute
        };

        pulseaudio = {
          format = "{icon} <sub>{volume}%</sub>";
          format-icons = {
            default = [
              "󰕿"
              "󰖀"
              "󰕾"
            ]; # nf-md-volume low / medium / high
          };
          format-muted = "󰝟"; # nf-md-volume_mute
        };

        clock = {
          format = "{:%m-%d %H:%M}";
          tooltip-format = "<tt><small>{calendar}</small></tt>";
          calendar = {
            mode = "year";
            mode-mon-col = 3;
            weeks-pos = "right";
            format = {
              weeks = "<span color='#7733ff'><b>W{:%W}</b></span>";
              today = "<span color='#00bfff'><b><u>{}</u></b></span>";
            };
          };
        };

        "wlr/taskbar" = {
          format = "{icon}";
          icon-size = 24;
          on-click = "minimize-raise";
          on-click-middle = "close";
        };

        "custom/quit" = {
          format = "󰩈"; # nf-md-exit_run
          tooltip = false;
          on-click =
            if isHyprland then
              "hyprctl dispatch exit"
            else
              (if isNiri then "niri msg action quit" else builtins.abort "Unconfirmed escape route :(");
        };
        "custom/shutdown" = {
          format = "󱄅"; # nf-md-nix
          tooltip = false;
          on-click = "systemctl poweroff";
        };
        "custom/reboot" = {
          format = "󱋋"; # nf-md-snowflake_melt
          tooltip = false;
          on-click = "systemctl reboot";
        };

        "group/power" = {
          orientation = "inherit";
          drawer.transition-left-to-right = false;
          modules = [
            "custom/quit"
            "custom/shutdown"
            "custom/reboot"
          ];
        };
      } // cfg.extraSettings;
      style = mkDefault ''
        * {
          border: unset;
          border-radius: 0;

          margin: 0;

          font-family: "Symbols Nerd Font Mono", "Sarasa Fixed Slab SC", sans-serif;
          font-size: 1.0rem;
        }

        window#waybar {
          background: transparent;

          color: white;
        }

        window#waybar .module {
          border-bottom: 2px solid #8e24aa;

          padding: 0 3px;
        }

        #window, #clock {
          font-style: italic;
        }

        #workspaces label, #power label {
          font-size: 24px;
        }

        /* LEFT */
        window#waybar.empty#window {
          border: unset;
        }

        /* CENTER */
        #workspaces button {
          color: white;
        }

        #workspaces button:hover {
          background: unset;
        }

        #workspaces button.focused {
          background: #8e24aa;
        }

        /* RIGHT */
        #custom-quit { color: #008000; }
        #custom-reboot { color: #fbc02d; }
        #custom-shutdown { color: #dc143c; }
      '';
    };
  };
}

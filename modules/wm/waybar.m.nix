{
  home =
    {
      lib,
      config,
      wmCfg,
      ...
    }:

    let
      inherit (lib)
        mkDefault
        mkOption

        types
        ;

      cfg = config.programs.waybar;

      iconSize = 24;
      fontSize = 13;

      # only the font property can be used with px
      nerd' =
        symbol: "<span font=\"Symbols Nerd Font Mono ${builtins.toString iconSize}px\">${symbol}</span>";

      # comma is important
      var' =
        text:
        "<span font=\"Vector Mono, Oblique Medium ${builtins.toString fontSize}px\" rise=\"-1pt\">${text}</span>";

      nerd = symbol: var: "${nerd' symbol} ${var' var}";
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

      config = lib.mkIf cfg.enable {
        programs.waybar = {
          systemd = {
            enable = true;
            enableInspect = false;
          };
          settings.mainBar = {
            layer = "top";
            height = 32;
            margin = "3px";
            spacing = 3;

            modules-left = cfg.left;
            modules-center = cfg.center;
            modules-right = cfg.right;

            tray = {
              icon-size = iconSize;
              spacing = 5;
              reverse-direction = true;
            };

            load = {
              format = nerd "󰑮" "{}"; # nf-md-run_fast
              tooltip = false;
            };

            network = {
              interval = 3;
              format-ethernet = "${var' "{bandwidthUpBits}"} ${nerd' "󰚮"} ${var' "{bandwidthDownBits}"}"; # nf-md-transit_transfer
              format-linked = nerd' "󰌚"; # nf-md-lan_pending
              format-disconnected = nerd' "󰌙"; # nf-md-lan_disconnect
              tooltip = false;
            };

            # [warning] [wireplumber]: (onMixerChanged) - Object with id xx not found
            wireplumber = {
              format = nerd "{icon}" "{volume}%";
              format-icons = [
                "󰕿"
                "󰖀"
                "󰕾"
              ]; # nf-md-volume low / medium / high
              format-muted = nerd' "󰝟"; # nf-md-volume_mute
            };

            pulseaudio = {
              format = nerd "{icon}" "{volume}%";
              format-icons = {
                default = [
                  "󰕿"
                  "󰖀"
                  "󰕾"
                ]; # nf-md-volume low / medium / high
              };
              format-muted = nerd' "󰝟"; # nf-md-volume_mute
              format-source-muted = nerd' "󰸈"; # nf-md-volume_variant_off
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

            systemd-failed-units = {
              format = nerd "󱡍" "{nr_failed_system}:{nr_failed_user}";
            };

            "wlr/taskbar" = {
              format = "{icon}";
              icon-size = iconSize;
              on-click = "minimize-raise";
              on-click-middle = "close";
            };

            "custom/quit" = {
              format = "󰩈"; # nf-md-exit_run
              tooltip = false;
              on-click =
                if wmCfg.isNiri then
                  "niri msg action quit"
                else
                  builtins.abort;
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

              font-family: "Sarasa UI SC", "Sarasa UI TC", "Sarasa UI HC", "Sarasa UI J", "Sarasa UI K", sans-serif;
              font-size: 14px;
            }

            window#waybar {
              background: transparent;

              color: white;
            }

            window#waybar .module {
              border-bottom: 3px solid #8e24aa;

              padding: 0 3px;
            }

            #window {
              font-style: italic;
            }

            #workspaces label, #power label {
              font-family: "Symbols Nerd Font Mono";
              font-size: ${builtins.toString iconSize}px;
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

            #systemd-failed-units.degraded { color: yellow; }

            #custom-quit { color: #008000; }
            #custom-reboot { color: #fbc02d; }
            #custom-shutdown { color: #dc143c; }
          '';
        };
      };
    };
}

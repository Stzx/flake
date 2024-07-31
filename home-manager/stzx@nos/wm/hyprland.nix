{ pkgs, ... }:

{
  home.packages = with pkgs.kdePackages; [
    breeze
    breeze-gtk

    qt6ct
  ];

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      gtk-theme = "Breeze-Dark";
      color-scheme = "prefer-dark";
      icon-theme = "Papirus";
      cursor-theme = "capitaine-cursors";
    };
  };

  home.pointerCursor = {
    package = pkgs.capitaine-cursors;
    name = "capitaine-cursors";
  };

  wayland.windowManager.hyprland = {
    enable = true;
    extraConfig = ''
      env = QT_QPA_PLATFORMTHEME,qt6ct

      exec-once = waybar
      exec-once = fcitx5 -d

      exec-once = [workspace 1 silent] firefox
      exec-once = [workspace special:terminal silent] kitty
      exec-once = [workspace special:chat silent] telegram-desktop
      exec-once = [workspace special:chat silent] thunderbird

      general {
        border_size = 2
        gaps_in = 6
        gaps_out = 12

        col.active_border = rgb(884dff) rgb(4da6ff) 45deg

        resize_on_border = true
      }

      decoration {
        drop_shadow = false

        dim_inactive = true
      }

      input {
        numlock_by_default = true
      }

      misc {
        disable_hyprland_logo = true
      }

      # main mod
      $mm = SUPER

      bind = $mm, Q, exec, tofi-drun | xargs hyprctl dispatch exec --
      bind = $mm, T, exec, kitty
      bind = $mm, C, exec, telegram-desktop
      bind = $mm, B, exec, firefox

      bind = $mm, P, pseudo,
      bind = $mm, S, togglesplit,
      bind = $mm, X, killactive,
      bind = $mm, V, togglefloating,
      bind = $mm, Escape, exit

      bind = $mm, 1, workspace, 1
      bind = $mm, 2, workspace, 2
      bind = $mm, 3, workspace, 3
      bind = $mm, 4, workspace, 4
      bind = $mm, 7, togglespecialworkspace, terminal
      bind = $mm, 8, togglespecialworkspace, music
      bind = $mm, 9, togglespecialworkspace, chat
      bind = $mm, 0, togglespecialworkspace, magic

      bind = $mm SHIFT, 1, movetoworkspace, 1
      bind = $mm SHIFT, 2, movetoworkspace, 2
      bind = $mm SHIFT, 3, movetoworkspace, 3
      bind = $mm SHIFT, 4, movetoworkspace, 4
      bind = $mm SHIFT, 7, movetoworkspace, special:terminal
      bind = $mm SHIFT, 8, movetoworkspace, special:music
      bind = $mm SHIFT, 9, movetoworkspace, special:chat
      bind = $mm SHIFT, 0, movetoworkspace, special:magic

      bind = $mm, h, resizeactive, -10 0
      bind = $mm, l, resizeactive, 10 0
      bind = $mm, k, resizeactive, 0 -10
      bind = $mm, j, resizeactive, 0 10

      bind = $mm SHIFT, h, movefocus, l
      bind = $mm SHIFT, l, movefocus, r
      bind = $mm SHIFT, k, movefocus, u
      bind = $mm SHIFT, j, movefocus, d

      bind = $mm CTRL, mounse_down, workspace, e+1
      bind = $mm CTRL, mounse_up, workspace, e-1
    '';
  };

  programs.waybar = {
    enable = true;
    settings = {
      mainBar = {
        margin = "6px 12px 0 12px";
        spacing = 6;
        modules-left = [ "hyprland/workspaces" "hyprland/window" ];
        modules-center = [ "clock" ];
        modules-right = [ "tray" "load" "wireplumber" "group/power" ];

        "hyprland/workspaces" = {
          all-outputs = true;
          format = "{icon}";
          format-icons = {
            active = "󰜎"; # nf-md-run
            default = ""; # nf-linux-wayland
            empty = "󰒲"; # nf-md-sleep
            special = "󰂵"; # nf-md-blur
          };
          show-special = true;
        };

        "hyprland/window" = {
          icon = true;
        };

        "clock" = {
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

        "tray" = {
          icon-size = 24;
          spacing = 12;
          reverse-direction = true;
        };

        "keyboard-state" = {
          numlock = true;
          capslock = true;
          scrolllock = true;
          format-icons = {
            locked = "󰨀"; # nf-md-lighthouse_on
            unlocked = "󰧿"; # nf-md-lighthouse
          };
        };

        "wireplumber" = {
          format-muted = ""; # nf-fa-volume_xmark
        };

        "custom/quit" = {
          format = "󰩈"; # nf-md-exit_run
          tooltip = false;
          on-click = "hyprctl dispatch exit";
        };
        "custom/shutdown" = {
          format = "󱄅"; # nf-md-nix
          tooltip = false;
          on-click = "systemctl poweroff";
        };
        "custom/reboot" = {
          format = "󰜉"; # nf-md-restart
          tooltip = false;
          on-click = "reboot";
        };
        "group/power" = {
          orientation = "inherit";
          drawer = {
            transition-left-to-right = false;
          };
          modules = [
            "custom/quit"
            "custom/shutdown"
            "custom/reboot"
          ];
        };
      };
    };
    style = ''
      * {
        font-family: "Symbols Nerd Font", "Sarasa UI SC", sans-serif;
        font-size: 16px;
      }

      window#waybar {
        border-bottom: 1px rgb(136,77,255) solid;
        background: transparent;
      }

      .modules-left button {
        border: 1px rgb(136,77,255) solid;
        border-radius: 0;
        margin-right: 6px;
        padding: 6px 12px;
      }

      .modules-right label {
        border-top: 1px rgb(136,77,255) solid;
        margin-left: 6px;
        padding: 6px 12px;
      }

      #workspaces .active {
        background: rgba(136,77,255,0.5);
      }

      #window {
        border-top: 1px rgb(136,77,255) solid;

        font-style: italic;
      }

      #power label.module {
        font-size: 24px;
      }

      #custom-quit {
        color: rgb(0,128,0);
      }

      #custom-shutdown {
        color: rgb(220,20,60);
      }

      #custom-reboot {
        color: rgb(135,206,250);
      }
    '';
  };

  programs.tofi = {
    enable = true;
    settings = {
      font = "Sarasa UI SC";
    };
  };
}


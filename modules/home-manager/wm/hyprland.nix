{ lib, pkgs, ... }:

let
  inherit (lib) mkIf isHyprland;
in
mkIf isHyprland {
  # NOTE: https://github.com/Alexays/Waybar/issues/2381
  systemd.user.services.waybar.Unit = rec {
    After = [ "wireplumber.service" ];
    Wants = After;
  };

  home.packages = with pkgs.kdePackages; [
    breeze
    breeze-gtk

    qt6ct
  ];

  services.playerctld.enable = true;

  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = false;
    extraConfig = ''
      env = QT_QPA_PLATFORMTHEME,qt6ct

      exec-once = fcitx5 -d
      exec-once = mako

      exec-once = [workspace 1 silent] firefox
      exec-once = [workspace special:terminal silent] kitty
      exec-once = [workspace special:chat silent] telegram-desktop
      exec-once = [workspace special:chat silent] thunderbird

      general {
        border_size = 1
        gaps_in = 3
        gaps_out = 6

        col.active_border = rgb(884dff) rgb(4da6ff) 45deg
      }

      decoration {
        drop_shadow = false

        dim_inactive = false
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

      bind = $mm, X, killactive,
      bind = $mm, V, togglefloating,
      bind = $mm, Escape, exit

      bind = $mm, 1, workspace, 1
      bind = $mm, 2, workspace, 2
      bind = $mm, 3, workspace, 3
      bind = $mm CTRL, 1, togglespecialworkspace, terminal
      bind = $mm CTRL, 2, togglespecialworkspace, chat
      bind = $mm CTRL, 3, togglespecialworkspace, magic

      bind = $mm SHIFT, 1, movetoworkspace, 1
      bind = $mm SHIFT, 2, movetoworkspace, 2
      bind = $mm SHIFT, 3, movetoworkspace, 3
      bind = $mm CTRL SHIFT, 1, movetoworkspace, special:terminal
      bind = $mm CTRL SHIFT, 2, movetoworkspace, special:chat
      bind = $mm CTEL SHIFT, 3, movetoworkspace, special:magic

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

      bindl=, XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
      bindl=, XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 1%-
      binde=, XF86AudioRaiseVolume, exec, wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 1%+

      bindl=, XF86AudioPrev, exec, playerctl previous
      bindl=, XF86AudioPlay, exec, playerctl play-pause
      bindl=, XF86AudioNext, exec, playerctl next

      # XF86HomePage, XF86Explorer, XF86Calculator
    '';
  };

  programs.waybar = {
    left = [
      "hyprland/window"
    ];
    center = [
      "hyprland/workspaces"
    ];
    right = [
      "tray"
      "load"
      "wireplumber"
      "network"
      "clock"
      "group/power"
    ];
  };
}
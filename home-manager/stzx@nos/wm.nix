{
  pkgs,
  lib,
  config,
  ...
}:

let
  inherit (lib) singleton;
in
{
  home.packages = with pkgs; [
    calibre
    librecad
    libreoffice

    qbittorrent
    obs-studio
    telegram-desktop
    spotify

    veracrypt
    keepassxc

    jetbrains-toolbox
  ];

  programs = {
    scrcpy = true;

    mpv.enable = true;

    zed-editor.enable = true;
  };

  systemd.user.services.fetch-ipfilter.Service.ExecStart =
    "${lib.getExe pkgs.curl} -o ${config.xdg.cacheHome}/ipfilter.p2p https://blocklist.binac.org/btn-all.p2p";

  systemd.user.timers.fetch-ipfilter.Timer = {
    OnCalendar = "*-*-* 21:00:00";
    Persistent = true;
  };

  programs.niri = {
    display = {
      primary = "DP-1";
      secondary = "DP-2";
    };
    settings = {
      spawn-at-startup = [
        { command = singleton "wezterm"; }
        { command = singleton "firefox"; }
        { command = singleton "thunderbird"; }
      ];
      input = {
        touchpad.enable = false;
        keyboard.numlock = true;
      };
      outputs = {
        "DP-1" = {
          focus-at-startup = true;
          variable-refresh-rate = "on-demand";
        };
        "DP-2".transform.rotation = 270;
      };
      window-rules = [
        {
          matches = [
            { app-id = "^Waydroid$"; }
            { app-id = "^calibre-ebook-viewer$"; }
          ];

          open-on-output = "DP-2";
          open-fullscreen = true;
        }
      ];
    };
  };

  programs.wezterm.userConfig = ''
    cfg.serial_ports = {
      {
        name = 'FT232RL',
        port = '/dev/ttyUSB0',
        baud = 115200,
      },
    }
  '';
}

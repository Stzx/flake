{
  pkgs,
  lib,
  config,
  ...
}:

{
  home.packages = with pkgs; [
    # qpwgraph

    helvum

    calibre
    librecad
    libreoffice

    qbittorrent
    telegram-desktop
    spotify

    veracrypt
    keepassxc

    jetbrains-toolbox

    global-quake-bin
  ];

  programs = {
    scrcpy = true;

    mpv.enable = true;
    obs-studio = {
      enable = true;
      plugins = with pkgs.obs-studio-plugins; [ obs-pipewire-audio-capture ];
    };

    zed-editor.enable = true;
  };

  systemd.user.services.fetch-ipfilter.Service = {
    Type = "oneshot";
    ExecStart = "${lib.getExe pkgs.curl} -v -o ${config.xdg.cacheHome}/ipfilter.p2p https://blocklist.binac.org/btn-all.p2p";
  };

  systemd.user.timers.fetch-ipfilter.Timer = {
    OnCalendar = "*-*-* 21:00:00";
    Persistent = true;
  };

  programs.niri = {
    display = {
      primary = "DP-1";
      secondary = "DP-2";
    };
    spawn-at-startup = ''
      spawn-at-startup "firefox"
      spawn-at-startup "thunderbird"
    '';
    window-rule = ''
      window-rule {
          match app-id="^Waydroid$"
          match app-id="^calibre-ebook-viewer$"

          open-on-output "DP-2"
          open-fullscreen true
      }
    '';
  };

  programs.wezterm.userConfig = ''
    cfg.animation_fps = 60

    cfg.serial_ports = {
      {
        name = 'FT232RL',
        port = '/dev/ttyUSB0',
        baud = 115200,
      },
    }
  '';
}

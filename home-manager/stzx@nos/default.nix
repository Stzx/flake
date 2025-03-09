{
  pkgs,
  lib,
  config,
  ...
}:

let
  email = "silence.m@hotmail.com";

  profile = "thunderbird.${config.home.username}";
in
{
  imports =
    [ ../. ]
    ++ lib.my.listNeedWM [
      {
        home.packages = with pkgs; [
          # calibre
          librecad
          libreoffice

          texlive.combined.scheme-full

          unrar
          qbittorrent
          obs-studio
          telegram-desktop

          veracrypt
          keepassxc

          jetbrains.rust-rover

          zed-editor
        ];

        accounts.email.accounts.${email} = {
          realName = "Silence Tai";
          address = email;
          primary = true;

          userName = email;
          imap = {
            host = "outlook.office365.com";
            port = 993;
          };
          smtp = {
            host = "smtp.office365.com";
            port = 587;
            tls.useStartTls = true;
          };

          thunderbird.enable = true;
        };

        programs = {
          firefox.enable = true;

          thunderbird = {
            enable = true;
            profiles.${profile}.isDefault = true;
          };

          mpv.enable = true;
        };
      }
    ];

  home.packages = with pkgs; [
    flac

    temurin-bin
  ];

  programs = {
    ssh.enable = true;

    adb = true;
    scrcpy = true;
    net-tools = true;
  };

  programs.git = {
    userName = "Stzx";
    userEmail = email;
  };

  programs.niri.settings = {
    input.touchpad.enable = false;
    outputs = {
      "DP-1".variable-refresh-rate = "on-demand";
      "DP-2".transform.rotation = 90;
    };
  };
}

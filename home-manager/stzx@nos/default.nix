{
  pkgs,
  lib,
  config,
  ...
}:

let
  inherit (lib) singleton;

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

          (texliveSmall.withPackages (
            ps: with ps; [
              roboto
              sourcesanspro
              fontawesome5

              ctex
              enumitem
              tcolorbox
              tikzfill
              ifmtarg
              xifthen
              xstring
            ]
          ))

          unrar
          qbittorrent
          obs-studio
          telegram-desktop

          veracrypt
          keepassxc

          jetbrains-toolbox
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
          thunderbird = {
            enable = true;
            profiles.${profile}.isDefault = true;
          };

          mpv.enable = true;
          zed-editor.enable = true;
        };
      }
    ];

  home.packages = with pkgs; [ flac ];

  programs = {
    ssh.enable = true;

    scrcpy = true;
    net-tools = true;
  };

  programs.bash = {
    enable = true;
    package = null;
    historyFileSize = 0;
    historySize = null;
  };

  programs.git = {
    userName = "Stzx";
    userEmail = email;
    delta.enable = true;
  };

  programs.niri.settings = {
    input.touchpad.enable = false;
    outputs = {
      "DP-1".variable-refresh-rate = "on-demand";
      "DP-2".transform.rotation = 90;
    };
    window-rules = [
      {
        matches = singleton { app-id = "Waydroid"; };

        open-on-output = "DP-2";
      }
    ];
  };
}

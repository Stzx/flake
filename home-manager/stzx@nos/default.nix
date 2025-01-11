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
          texstudio

          mpv
          obs-studio
          qbittorrent
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
        };

        xdg.configFile."mpv/mpv.conf".text = ''
          profile=gpu-hq

          fs=yes
          mute=yes
          keepaspect=yes

          alang=chi,zh,en
          slang=chi,zh,en
        '';
      }
    ];

  home.packages = with pkgs; [
    flac

    temurin-bin
  ];

  programs = {
    ssh.enable = true;

    adb = true;
    net-tools = true;
  };

  programs.git = {
    userName = "Stzx";
    userEmail = email;
  };
}

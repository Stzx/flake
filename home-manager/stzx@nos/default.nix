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
    with lib;
    [ ../. ]
    ++ optionals isKDE [
      ./wm/kde.nix
    ]
    ++ optionals isHyprland [
      ./wm/hyprland.nix
    ]
    ++ my.listNeedWM [
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
        ];

        accounts.email.accounts.${email}.thunderbird.enable = true;

        programs = {
          firefox.enable = true;
          thunderbird = {
            enable = true;
            profiles.${profile}.isDefault = true;
          };
        };
      }
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
  };

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

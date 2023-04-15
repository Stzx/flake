{ config, lib, dotsPath, ... }:

let
  email = "silence.m@hotmail.com";

  profile = "thunderbird.${config.home.username}";
in
{
  config = lib.mkMerge [
    {
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

      programs.git = {
        enable = true;
        userName = "Stzx";
        userEmail = email;
      };

      programs.ssh.enable = true;
    }

    (lib.mkIf lib.my.haveAnyDE {
      xdg = {
        configFile = {
          "fcitx5/profile".source = dotsPath + /fcitx5/profile;
          "fcitx5/conf/pinyin.conf".source = dotsPath + /fcitx5/pinyin.conf;
          "fcitx5/conf/cloudpinyin.conf".source = dotsPath + /fcitx5/cloudpinyin.conf;
          "fcitx5/conf/classicui.conf".source = dotsPath + /fcitx5/classicui.conf;
          "fcitx5/conf/chttrans.conf".source = dotsPath + /fcitx5/chttrans.conf;
        };
        dataFile = {
          "fcitx5/themes/material-theme/theme.conf".source = dotsPath + /fcitx5/fcitx5-material-themes/theme-deepPurple.conf;
        };
      };

      accounts.email.accounts.${email}.thunderbird.enable = true;

      programs.thunderbird = {
        enable = true;
        profiles.${profile}.isDefault = true;
      };
    })
  ];
}

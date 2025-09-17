{
  pkgs,
  lib,
  config,
  sysCfg,
  ...
}:

let
  email = "silence.m@hotmail.com";
in
{
  imports = lib.optional sysCfg.wm.enable ./wm.nix;

  config = {
    home.packages = with pkgs; [
      fuse-archive
      fuse-avfs # original name: avfs
    ];

    programs = {
      ssh.enable = true;
      direnv.enable = true;

      rmpc.enable = true;
    };

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

      thunderbird.enable = config.programs.thunderbird.enable;
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

    programs.thunderbird = {
      enable = sysCfg.wm.enable;
      package = pkgs.thunderbird-esr;
    };
  };
}

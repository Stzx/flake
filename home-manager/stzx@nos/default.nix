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

      bat
      numbat

      android-tools
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

      thunderbird = {
        enable = config.programs.thunderbird.enable;
        settings = id: {
          # 1 = No authentication, 3(default) = Normal pwd, 4 = Encrypted pwd, 5 = Kerberos / GSSAPI, 6 = NTLM, 10 = OAuth2
          "mail.smtpserver.smtp_${id}.authMethod" = 10;
        };
      };
    };

    programs.bash = {
      enable = true;
      package = null;
      historyFileSize = 0;
      historySize = null;
    };

    programs.git.settings.user = {
      inherit email;

      name = "Stzx";
    };

    programs.thunderbird = {
      enable = sysCfg.wm.enable;
      package = pkgs.thunderbird-esr;
    };
  };
}

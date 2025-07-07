{ pkgs, config, ... }:

let
  email = config.programs.git.userEmail;
in
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

    thunderbird.enable = true;
  };

  programs.thunderbird = {
    enable = true;
    package = pkgs.thunderbird-esr;
  };
}

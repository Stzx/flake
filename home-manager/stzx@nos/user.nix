{ lib
, config
, ...
}:

let
  email = "silence.m@hotmail.com";

  profile = "thunderbird.${config.home.username}";
in
lib.mkMerge [
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
  }

  (lib.mkIf lib.my.haveAnyDE {
    accounts.email.accounts.${email}.thunderbird.enable = true;

    programs.thunderbird = {
      enable = true;
      profiles.${profile}.isDefault = true;
    };
  })
]

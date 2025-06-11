{
  home =
    {
      lib,
      config,
      ...
    }:

    let
      inherit (lib) mkIf;

      profile = "thunderbird.${config.home.username}";
    in
    {
      config = mkIf config.programs.thunderbird.enable (
        lib.mkMerge [
          {
            programs.thunderbird.profiles."${profile}" = {
              isDefault = true;
              feedAccounts."${profile}" = { };
              search = {
                default = "bing";
                force = true;
              };
              settings = {
                "browser.region.update.enabled" = false;

                "toolkit.telemetry.enabled" = false;
                "toolkit.telemetry.archive.enabled" = false;
                "toolkit.telemetry.unified" = false;

                "datareporting.usage.uploadEnabled" = false;
                "datareporting.healthreport.uploadEnabled" = false;
                "datareporting.policy.dataSubmissionEnabled" = false;
              };
            };
          }
        ]
      );
    };
}

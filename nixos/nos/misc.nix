{ lib, ... }:
{
  # for game
  services.flatpak.enable = true;

  services.boinc.enable = true;

  services.prometheus = {
    enable = true;
    listenAddress = "127.0.0.1";
    scrapeConfigs = lib.singleton {
      job_name = "self";
      static_configs = lib.singleton {
        targets = [ "127.0.0.1:9100" ];
      };
    };
    exporters.node = {
      enable = true;
      listenAddress = "127.0.0.1";
      disabledCollectors = [ "zfs" "infiniband" "fibrechannel" ];
    };
  };

  services.grafana = {
    enable = true;
    settings = {
      analytics = {
        reporting_enabled = false;
        feedback_links_enabled = false;
      };
    };
  };

  virtualisation.docker = {
    enable = true;
    enableOnBoot = false;
  };
}

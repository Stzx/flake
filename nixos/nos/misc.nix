{
  self,
  lib,
  utils,
  config,
  ...
}:

let
  inherit (lib) singleton;

  varPrometheus = config.systemd.services.prometheus.serviceConfig.WorkingDirectory;
in
{
  services.flatpak.enable = true;

  # services.fwupd.enable = false;

  systemd = {
    mounts = [
      rec {
        type = "tmpfs";
        what = type;
        where = varPrometheus;
        options = builtins.concatStringsSep "," self.lib.dataOptions;
      }
    ];
    services.prometheus.unitConfig = rec {
      Requires = singleton "${utils.escapeSystemdPath varPrometheus}.mount";
      After = Requires;
    };
  };

  services.prometheus = {
    enable = true;
    listenAddress = "127.0.0.1";
    stateDir = "prometheus-ram";
    globalConfig = {
      scrape_interval = "15s";
      evaluation_interval = "15s";
    };
    scrapeConfigs = singleton {
      job_name = "prometheus";
      static_configs = singleton { targets = singleton "127.0.0.1:9090"; };
    };
    exporters.node = {
      enable = true;
      listenAddress = "127.0.0.1";
      enabledCollectors = lib.optional config.features.gpu.amd "drm";
      disabledCollectors = [
        "bcache"
        "zfs"
        "infiniband"
        "fibrechannel"
        "tapestats"
      ];
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

  services.ollama.enable = false;

  virtualisation.waydroid.enable = true;

  virtualisation.docker = {
    enable = false;
    enableOnBoot = false;
  };

  virtualisation.libvirtd = {
    enable = false;
    onBoot = "ignore";
    qemu.swtpm.enable = true;
  };
}

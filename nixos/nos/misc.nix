{
  self,
  pkgs,
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
  programs.ccache = {
    enable = true;
    packageNames = [ "mpv-unwrapped" ]; # mainly used to enable ccacheWrapper
  };

  programs.adb.enable = true;

  services.flatpak.enable = true;

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
    scrapeConfigs = singleton {
      job_name = "prometheus";
      static_configs = singleton { targets = singleton "127.0.0.1:9090"; };
    };
    exporters.node = {
      enable = true;
      listenAddress = "127.0.0.1";
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

  virtualisation.libvirtd = {
    enable = true;
    onBoot = "ignore";
    qemu.swtpm.enable = true;
  };
}

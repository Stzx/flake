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

  # GAME
  # com.valvesoftware.Steam
  # com.valvesoftware.Steam.CompatibilityTool.Proton-GE
  # org.freedesktop.Platform.VulkanLayer.MangoHud
  #
  # ? org.freedesktop.Platform.VulkanLayer.gamescope
  #
  # flatpak override --user --env=PROTON_ENABLE_WAYLAND=1 --env=MANGOHUD=1 --filesystem=xdg-config/MangoHud:ro --filesystem=/nix/store:ro com.valvesoftware.Steam
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

  programs.java = {
    package = pkgs.temurin-jre-bin;
    binfmt = true;
  };

  virtualisation.waydroid.enable = true;

  virtualisation.libvirtd = {
    enable = true;
    onBoot = "ignore";
    qemu.swtpm.enable = true;
  };
}

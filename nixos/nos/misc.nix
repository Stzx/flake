{ lib, pkgs, ... }:

{
  services.flatpak.enable = true;

  services.prometheus = {
    enable = true;
    listenAddress = "127.0.0.1";
    scrapeConfigs = [
      {
        job_name = "prometheus";
        static_configs = lib.singleton { targets = [ "127.0.0.1:9090" ]; };
      }

      {
        job_name = "node";
        static_configs = lib.singleton { targets = [ "127.0.0.1:9100" ]; };
      }
    ];
    exporters.node = {
      enable = true;
      listenAddress = "127.0.0.1";
      disabledCollectors = [
        "zfs"
        "infiniband"
        "fibrechannel"
        "bcache"
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
    enable = true;
    package = pkgs.temurin-jre-bin;
    binfmt = true;
  };

  virtualisation.waydroid.enable = true;

  virtualisation.libvirtd = {
    enable = true;
    onBoot = "ignore";
    qemu.swtpm.enable = true;
  };

  users.extraUsers.stzx.extraGroups = [ "libvirtd" ];
}

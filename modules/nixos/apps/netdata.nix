{ config, lib, pkgs, ... }:

let
  cfg = config.features;

  pkg = config.services.netdata.package;
in
{
  options.features = {
    netdata = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Install NETDATA";
    };
  };

  config = lib.mkIf cfg.netdata {
    services.netdata = {
      enable = true;
      python.enable = false;
      config = {
        db = {
          mode = "ram";
          retention = 36000;
        };
        ml.enabled = "no";
        health.enabled = "no";
        plugins = {
          "tc" = "no";
          "cgroups" = "no";
          "enable running new plugins" = "no";
          "go.d" = "no";
          "charts.d" = "no";
          "statsd" = "no";
          "ioping" = "no";
          "python.d" = "no";
          "apps" = "no";
          "freeipmi" = "no";
        };
        "plugin:proc" = {
          "/sys/devices/system/node" = "no";
        };
        "plugin:proc:diskspace" = {
          "exclude space metrics on paths" = "/dev/mapper/* /proc/* /sys/* /var/run/user/* /run/user/* /snap/* /var/lib/docker/*";
        };
      };
    };

    # FIXME: https://github.com/NixOS/nixpkgs/pull/244789
    systemd.services.netdata.serviceConfig.ExecStartPost = lib.mkForce (pkgs.writeShellScript "wait-for-netdata-up" ''
      while [ ! -e "$NETDATA_PIPENAME" ] || [ "$(${pkg}/bin/netdatacli ping)" != "pong" ]; do sleep 0.5; done
    '');
  };
}

{
  lib,
  config,
  secrets,
  ...
}:

let
  inherit (lib.my) byNVMeEui btrfsOptions;

  nvme = "${byNVMeEui secrets.origin-eui}";
in
{
  disko.devices = {
    disk.nvme = {
      type = "disk";
      device = nvme;
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            device = "${nvme}-part1";
            size = "1G";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [ "umask=0077" ];
            };
          };
          ORIGIN = {
            device = "${nvme}-part2";
            size = "100%";
            content = {
              type = "btrfs";
              extraArgs = [
                "--checksum sha256"
                "-f"
              ];
              subvolumes = {
                "/${config.networking.hostName}" = {
                  mountpoint = "/";
                  mountOptions = btrfsOptions;
                };
                "/nix" = {
                  mountpoint = "/nix";
                  mountOptions = btrfsOptions;
                };
                "/home" = {
                  mountpoint = "/home";
                  mountOptions = btrfsOptions;
                };
                "/snapshots" = { };
              };
            };
          };
        };
      };
    };
  };

  zramSwap = {
    enable = true;
    algorithm = "lzo-rle";
  };

  virtualisation.docker.storageDriver = "btrfs";
}

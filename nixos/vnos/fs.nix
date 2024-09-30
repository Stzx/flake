{ lib, config, ... }:

let
  inherit (lib.my) btrfsOptions;
in
{
  disko.devices = {
    disk.vda = {
      device = "/dev/disk/by-diskseq/1";
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            name = "ESP";
            size = "1G";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
            };
          };
          ORIGIN = {
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
              };
            };
          };
        };
      };
    };
  };
}

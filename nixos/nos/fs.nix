{
  self,
  config,
  values,
  ...
}:

let
  inherit (self.lib) byNVMeEui btrfsOptions;

  nvme = "${byNVMeEui values.origin-eui}";
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
                "--checksum blake2"
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

  virtualisation.docker.storageDriver = "btrfs";
}

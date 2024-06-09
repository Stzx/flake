{ pkgs
, lib
, config
, ...
}:

let
  inherit (lib.my) btrfsOptions;
in
{
  features = {
    desktop.kde = true;
  };

  virtualisation.virtualbox.guest.enable = true;

  users.extraUsers = {
    "root".hashedPassword = "$y$j9T$ANV6NJ.3Cv9tNkz3N5F0i.$nWqLkgTczHrSqgJV43aQXLC3RsxRUHt2m6UtYHR6z65";
    "drop" = {
      uid = 1000;
      description = "Drop Life";
      extraGroups = [ "wheel" "vboxsf" "keys" ];
      initialHashedPassword = "$y$j9T$WA15P5KSXU46ifui64PGK1$z7aLN5VD4oRoQ1TpLdRsEorXF6TEh7P3fiuVvacAs3B";
      isNormalUser = true;
    };
  };
} // {
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
              extraArgs = [ "--checksum sha256" "-f" ];
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

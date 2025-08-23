{ lib }:

let
  inherit (builtins) elemAt;

  ccOptions = options: builtins.concatStringsSep "," options;

  mergeInit = {
    mounts = [ ];
    automounts = [ ];
  };

  mergeUnit = acc: unit: {
    mounts = acc.mounts ++ unit.mounts;
    automounts = acc.automounts ++ unit.automounts;
  };
in
rec {
  byUuid = uuid: "/dev/disk/by-uuid/${uuid}";

  byId = id: "/dev/disk/by-id/${id}";

  byLabel = label: "/dev/disk/by-label/${label}";

  byNVMeEui = eui: byId "nvme-eui.${eui}";

  timeOptions = [
    "noatime"
    "lazytime"
  ];

  dataOptions = [
    "nosuid"
    "nodev"
    "noexec"
  ]
  ++ timeOptions;

  btrfsOptions = [ "compress=zstd:3" ] ++ timeOptions;

  subvolBtrfsOptions = subvol: btrfsOptions ++ [ "subvol=${subvol}" ];

  xfsOptions = [

  ]
  ++ timeOptions;

  # see: https://www.kernel.org/doc/html/latest/filesystems/f2fs.html
  f2fsOptions = [
    "atgc"
    "flush_merge"
    "gc_merge"
    "compress_algorithm=zstd:6"
    "compress_chksum"
  ]
  ++ timeOptions;

  exfatOptions = [

  ]
  ++ timeOptions;

  mergeMounts' = mounts: lib.foldl mergeUnit mergeInit mounts;

  # [ [ UUID [ [ SUBVOL MOUNT_POINT OPTIONS AUTO_MOUNT ] ] ] ]

  btrfsMounts =
    devices:

    mergeMounts' (
      lib.flatten (
        lib.forEach devices (
          device:

          let
            uuid = (elemAt device 0);

            map' = info: uuid: {
              mounts = lib.singleton {
                what = byUuid uuid;
                where = (elemAt info 1);
                type = "btrfs";
                options = ccOptions ((elemAt info 2) ++ (subvolBtrfsOptions (elemAt info 0)));
              };
              automounts = lib.optional (elemAt info 3) {
                where = (elemAt info 1);
                wantedBy = [ "multi-user.target" ];
              };
            };
          in
          lib.forEach (elemAt device 1) (info: map' info uuid)
        )
      )
    );

  # [ [ UUID MOUNT_POINT OPTIONS AUTO_MOUNT ] ]
  mounts' =
    devices: fs: defaultOption:

    mergeMounts' (
      lib.forEach devices (device: {
        mounts = lib.singleton {
          what = byUuid (elemAt device 0);
          where = (elemAt device 1);
          type = fs;
          options = ccOptions ((elemAt device 2) ++ defaultOption);
        };
        automounts = lib.optional (elemAt device 3) {
          where = (elemAt device 1);
          wantedBy = [ "multi-user.target" ];
        };
      })
    );

  xfsMounts = devices: mounts' devices "xfs" xfsOptions;

  f2fsMounts = devices: mounts' devices "f2fs" f2fsOptions;

  exfatMounts = devices: mounts' devices "exfat" exfatOptions;
}

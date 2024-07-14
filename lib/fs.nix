{ lib }:

let
  inherit (builtins) elemAt;

  mergeUnit = a: b: {
    mounts = (a.mounts or [ ]) ++ b.mounts;
    automounts = (a.automounts or [ ]) ++ b.automounts;
  };
in
rec {
  byUUID = uuid: "/dev/disk/by-uuid/${uuid}";

  nvmeEui = eui: "/dev/disk/by-id/nvme-eui.${eui}";

  lineOptions = options: builtins.concatStringsSep "," options;

  timeOptions = [ "noatime" "lazytime" ];

  dataOptions = [ "nosuid" "nodev" "noexec" ] ++ timeOptions;

  btrfsOptions = (lib.singleton "compress=zstd") ++ timeOptions;

  subvolBtrfsOptions = subvol: btrfsOptions ++ (lib.singleton "subvol=${subvol}");

  f2fsOptions = [ "compress_algorithm=zstd" "compress_chksum" "atgc" "gc_merge" ] ++ timeOptions;

  fstab = { device, fsType, mountPoint, subvol ? mountPoint }: {
    "${mountPoint}" = {
      inherit device fsType;
      options =
        if (fsType == "vfat") then timeOptions
        else if (fsType == "btrfs") then (subvolBtrfsOptions subvol)
        else builtins.abort "fsType: ${fsType} unsupported";
    };
  };
  # [ [ UUID MOUNT_POINT AUTO_MOUNT ] ]
  f2fsMountUnit = devices: lib.foldl mergeUnit { } (lib.forEach devices (i: {
    mounts = lib.singleton {
      what = byUUID (elemAt i 0);
      where = elemAt i 1;
      type = "f2fs";
      options = lineOptions f2fsOptions;
    };
    automounts = lib.optional (elemAt i 2) {
      where = elemAt i 1;
      wantedBy = [ "multi-user.target" ];
    };
  }));

  # [ [ UUID [ [ SUBVOL MOUNT_POINT AUTO_MOUNT ] ] ] ]
  btrfsMountUnit = devices: lib.foldl mergeUnit { } (lib.flatten
    (lib.forEach devices (i:
      (lib.forEach (elemAt i 1) (ee: {
        mounts = lib.singleton {
          what = byUUID (elemAt i 0);
          where = elemAt ee 1;
          type = "btrfs";
          options = lineOptions (subvolBtrfsOptions (elemAt ee 0));
        };
        automounts = lib.optional (elemAt ee 2) {
          where = elemAt ee 1;
          wantedBy = [ "multi-user.target" ];
        };
      }))
    ))
  );
}

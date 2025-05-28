{ lib }:

let
  inherit (builtins) elemAt;

  concatOptions = options: builtins.concatStringsSep "," options;

  mergeUnit = a: b: {
    mounts = (a.mounts or [ ]) ++ b.mounts;
    automounts = (a.automounts or [ ]) ++ b.automounts;
  };
in
rec {
  byUuid = uuid: "/dev/disk/by-uuid/${uuid}";

  byId = id: "/dev/disk/by-id/${id}";

  byNVMeEui = eui: byId "nvme-eui.${eui}";

  timeOptions = [
    "noatime"
    "lazytime"
  ];

  dataOptions = [
    "nosuid"
    "nodev"
    "noexec"
  ] ++ timeOptions;

  btrfsOptions = (lib.singleton "compress=zstd") ++ timeOptions;

  subvolBtrfsOptions = subvol: btrfsOptions ++ (lib.singleton "subvol=${subvol}");

  f2fsOptions = [
    "compress_algorithm=zstd"
    "compress_chksum"
    "atgc"
    "gc_merge"
  ] ++ timeOptions;

  fstab =
    {
      device,
      fsType,
      mountPoint,
      subvol ? mountPoint,
    }:
    {
      "${mountPoint}" = {
        inherit device fsType;
        options =
          if (fsType == "vfat") then
            timeOptions
          else if (fsType == "btrfs") then
            (subvolBtrfsOptions subvol)
          else
            builtins.abort "fsType: ${fsType} unsupported";
      };
    };

  # [ [ UUID MOUNT_POINT AUTO_MOUNT ] ]
  simpleMountUnit =
    devices: fs: options:
    lib.foldl mergeUnit { } (
      lib.forEach devices (i: {
        mounts = lib.singleton {
          what = byUuid (elemAt i 0);
          where = elemAt i 1;
          type = fs;
          options = concatOptions options;
        };
        automounts = lib.optional (elemAt i 2) {
          where = elemAt i 1;
          wantedBy = [ "multi-user.target" ];
        };
      })
    );

  exfatMountUnit = devices: simpleMountUnit devices "exfat" [ ];

  f2fsMountUnit = devices: simpleMountUnit devices "f2fs" f2fsOptions;

  # [ [ UUID [ [ SUBVOL MOUNT_POINT AUTO_MOUNT ] ] ] ]
  btrfsMountUnit =
    devices:
    lib.foldl mergeUnit { } (
      lib.flatten (
        lib.forEach devices (
          i:
          (lib.forEach (elemAt i 1) (ee: {
            mounts = lib.singleton {
              what = byUuid (elemAt i 0);
              where = elemAt ee 1;
              type = "btrfs";
              options = concatOptions (subvolBtrfsOptions (elemAt ee 0));
            };
            automounts = lib.optional (elemAt ee 2) {
              where = elemAt ee 1;
              wantedBy = [ "multi-user.target" ];
            };
          }))
        )
      )
    );
}

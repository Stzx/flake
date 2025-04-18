{
  lib,
  config,
}:

let
  kernel = import ./kernel.nix { inherit lib; };

  fs = import ./fs.nix { inherit lib; };

  service = import ./service.nix { inherit config; };

  wm = import ./wm.nix { inherit config lib; };
in
{
  inherit (kernel) mkPatch mkPatchs;

  inherit (fs)
    byUuid
    byId
    byNVMeEui
    fstab
    timeOptions
    btrfsOptions
    f2fsOptions
    btrfsMountUnit
    exfatMountUnit
    f2fsMountUnit
    ;

  inherit (service)
    afterServices
    afterMultiUserTarget
    afterGraphicalTarget
    ;

  inherit (wm)
    isKDE
    isHyprland
    isNiri
    haveAnyWM
    attrNeedWM
    listNeedWM
    ;
}

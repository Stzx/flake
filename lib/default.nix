{ lib
, config
}:

let
  kernel = import ./kernel.nix { inherit lib; };

  fs = import ./fs.nix { inherit lib; };

  desktop = import ./desktop.nix { inherit config lib; };
in
{
  inherit (kernel) mkPatch mkPatchs;

  inherit (fs) byUuid byId byNVMeEui fstab timeOptions btrfsOptions f2fsOptions btrfsMountUnit f2fsMountUnit;

  inherit (desktop) isKDE haveAnyDE attrNeedDE listNeedDE desktopAssert;
}

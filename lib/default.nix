{
  mkPkgs,
  mkSystem,
  mkHomeManager,
  lib,
  ...
}:

let
  kernel = import ./kernel.nix { inherit lib; };

  fs = import ./fs.nix { inherit lib; };

  modules = import ./modules.nix { inherit lib; };

  wm' = import ./wm.nix { inherit lib; };
in
{
  inherit mkPkgs mkSystem mkHomeManager;

  inherit (kernel) mkPatch mkPatchs;

  inherit (fs)
    byUuid
    byId
    byNVMeEui
    fstab
    timeOptions
    dataOptions
    btrfsOptions
    f2fsOptions
    btrfsMountUnit
    exfatMountUnit
    f2fsMountUnit
    ;

  inherit wm';

  scanModules = modules;
}

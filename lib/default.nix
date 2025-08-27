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
in
{
  inherit mkPkgs mkSystem mkHomeManager;

  inherit (kernel) mkPatch mkPatchs;

  inherit (fs)
    byUuid
    byId
    byLabel
    byNVMeEui

    timeOptions
    dataOptions
    btrfsOptions
    xfsOptions
    f2fsOptions
    exfaOptions

    mergeMounts'

    btrfsMounts
    xfsMounts
    f2fsMounts
    exfatMounts
    ;

  scanModules = modules;
}

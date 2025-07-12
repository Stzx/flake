{
  pkgs,
  lib,
  ...
}:

let
  inherit (lib) mkForce;
in
{
  boot = {
    kernelPackages = pkgs.linuxPackages_xanmod;
    initrd = {
      includeDefaultModules = false;
      availableKernelModules = mkForce [
        "sha256"
        "amdgpu"
      ];
    };
    kernelParams = [ "libahci.ignore_sss=1" ];
    kernelModules = mkForce [
      "ntsync"
    ];
    supportedFilesystems = [
      "f2fs"
      "xfs"
      "exfat"
    ];
  };
}

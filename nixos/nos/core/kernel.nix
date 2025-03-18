{
  pkgs,
  lib,
  ...
}:

{
  boot = {
    kernelPackages = pkgs.linuxPackages_xanmod;
    initrd = {
      includeDefaultModules = false;
      availableKernelModules = lib.mkForce [
        "sha256"
        "amdgpu"
      ];
    };
    kernelParams = [ "libahci.ignore_sss=1" ];
    supportedFilesystems = [
      "f2fs"
      "xfs"
      "exfat"
    ];
  };
}

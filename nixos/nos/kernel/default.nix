{ lib, pkgs, ... }:

let
  linuxPackages_xanmod = pkgs.linuxPackages_xanmod.extend (_: prev: {
    kernel = pkgs.linuxManualConfig {
      inherit (prev.kernel) src version modDirVersion;

      configfile = ./defconfig;
      allowImportFromDerivation = true;
    };
  });
in
{
  boot = {
    kernelPackages = linuxPackages_xanmod;
    initrd = {
      includeDefaultModules = false;
      kernelModules = lib.mkForce [ "amdgpu" ];
    };
    kernelParams = [ ];
    kernelModules = lib.mkForce [ ];
    supportedFilesystems = [ "f2fs" "xfs" "exfat" ];
  };

  services.udev.extraRules = ''
    ACTION=="add", KERNEL=="0000:08:00.0", SUBSYSTEM=="pci", RUN:="${pkgs.bash}/bin/bash -c 'echo 1 | tee /sys/bus/pci/devices/0000:08:00.0/remove'"
  '';
}

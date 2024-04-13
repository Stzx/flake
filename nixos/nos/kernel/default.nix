{ lib, pkgs, ... }:

let
  linuxPackages_xanmod = pkgs.linuxPackages_xanmod.extend (_: prev: {
    kernel = (pkgs.linuxManualConfig {
      inherit (prev.kernel) src version modDirVersion;

      # FIXME: https://github.com/NixOS/nixpkgs/issues/49894
      # see https://github.com/NixOS/nixpkgs/issues/142901
      stdenv = with pkgs; overrideCC clangStdenv (clangStdenv.cc.override {
        inherit (llvmPackages) bintools;
        # LTO: override bintools sharedLibraryLoader = null;
      });
      # LTO: extraMakeFlags = [ "LLVM=1" ];

      configfile = ./def;
      allowImportFromDerivation = true;
      extraMeta = prev.kernel.meta;
    }).overrideAttrs (_: attrPrev: {
      hardeningDisable = attrPrev.hardeningDisable ++ [ "strictoverflow" ];
    });
  });
in
{
  boot = {
    kernelPackages = linuxPackages_xanmod;
    initrd = {
      includeDefaultModules = false;
      availableKernelModules = lib.mkForce [ "sha256_generic" ];
      kernelModules = lib.mkForce [ "amdgpu" ];
    };
    kernelParams = [ "libahci.ignore_sss=1" ];
    supportedFilesystems = [ "f2fs" "xfs" "exfat" ];
  };

  services.udev.extraRules = ''
    ACTION=="add", KERNEL=="0000:08:00.0", SUBSYSTEM=="pci", RUN:="${pkgs.bash}/bin/bash -c 'echo 1 | tee /sys/bus/pci/devices/0000:08:00.0/remove'"
  '';
}

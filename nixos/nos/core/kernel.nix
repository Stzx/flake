{ pkgs
, lib
, ...
}:

let
  xanmod = pkgs.linuxPackages_xanmod.extend (_: prev: {
    kernel = (pkgs.linuxManualConfig {
      inherit (prev.kernel) src version modDirVersion;

      # FIXME: https://github.com/NixOS/nixpkgs/issues/49894
      # see https://github.com/NixOS/nixpkgs/issues/142901
      stdenv = with pkgs; overrideCC clangStdenv (clangStdenv.cc.override {
        inherit (llvmPackages) bintools;
        # LTO: override bintools sharedLibraryLoader = null;
      });
      # LTO: extraMakeFlags = [ "LLVM=1" ];

      configfile = ./kernel-configuration;
      allowImportFromDerivation = true;
      extraMeta = prev.kernel.meta;
    }).overrideAttrs (_: attrPrev: {
      hardeningDisable = attrPrev.hardeningDisable ++ [ "strictoverflow" ];
    });
  });
in
{
  boot = {
    kernelPackages = xanmod;
    initrd = {
      includeDefaultModules = false;
      availableKernelModules = lib.mkForce [ "amdgpu" ];
    };
    kernelParams = [ "libahci.ignore_sss=1" "fsck.mode=skip" ];
    supportedFilesystems = [ "f2fs" "xfs" "exfat" ];
  };
}

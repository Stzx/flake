{
  pkgs,
  lib,
  ...
}:

let
  inherit (lib) mkForce;
in
{
  security.lsm = mkForce [ ];

  boot = {
    kernelPackages = pkgs.linuxPackages_xanmod_stable;
    kernelPatches = [
      # {
      #   name = "0001-bore";
      #   patch = pkgs.fetchurl {
      #     url = "https://github.com/firelzrd/bore-scheduler/raw/refs/heads/main/patches/stable/linux-6.15-bore/0001-linux6.15.6-bore-6.1.0.patch";
      #     hash = "sha256-V8fLXO1ryfThRyeo7Nl55ibLrD0hOJgYTUYJvpqiemE=";
      #   };
      # }
      # {
      #   name = "0002-bore";
      #   patch = pkgs.fetchurl {
      #     url = "https://github.com/firelzrd/bore-scheduler/raw/refs/heads/main/patches/stable/linux-6.15-bore/0002-sched-fair-Prefer-full-idle-SMT-cores.patch";
      #     hash = "sha256-xoe0CdAyS8jAnF++LQBdUJ26pylYlP8KSh3W2bYSVcY=";
      #   };
      # }
    ];
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

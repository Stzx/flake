{
  pkgs,
  lib,
  config,
  ...
}:

let
  inherit (lib) mkForce;
in
{
  environment.systemPackages = [
    pkgs.sbctl # lanzaboote
  ];

  boot = {
    loader.systemd-boot.enable = lib.mkForce false; # lanzaboote
    lanzaboote = {
      enable = true;
      pkiBundle = "/var/lib/sbctl";
    };

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
      systemd.enable = true;
      includeDefaultModules = false;
      availableKernelModules = mkForce [
        "amdgpu"
      ];
    };
    kernelParams = [
      "libahci.ignore_sss=1"
      "amdgpu.ppfeaturemask=0xfff7ffff"
    ];
    kernelModules = mkForce [
      "ntsync"
    ];
    supportedFilesystems = [
      "f2fs"
      "xfs"
      "exfat"
    ]
    ++ lib.optional config.virtualisation.waydroid.enable "ext4";
  };

  security.lsm = mkForce [ ];
}

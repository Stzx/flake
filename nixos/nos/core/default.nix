{
  pkgs,
  lib,
  config,
  ...
}:

let
  amdGpu = config.features.gpu.amd;
in
{
  imports = [ ./kernel.nix ];

  environment.systemPackages = [
    pkgs.sbctl # lanzaboote
  ];

  boot.loader.systemd-boot.enable = lib.mkForce false; # lanzaboote
  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/etc/secureboot";
  };

  services.udev.extraRules = ''
    ${lib.optionalString amdGpu ''SUBSYSTEM=="pci", DRIVER=="amdgpu", ATTR{power_dpm_force_performance_level}="manual", ATTR{pp_power_profile_mode}="2"''}

    ACTION=="add", KERNEL=="0000:08:00.0", SUBSYSTEM=="pci", RUN:="${pkgs.bash}/bin/bash -c 'echo 1 | tee /sys/bus/pci/devices/0000:08:00.0/remove'"
  '';

  services.journald.extraConfig = ''
    MaxRetentionSec=1week
  '';
}

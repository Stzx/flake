{
  pkgs,
  lib,
  ...
}:

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

  systemd.oomd.enable = false;

  services.udev.extraRules = ''
    ACTION=="add", KERNEL=="0000:08:00.0", SUBSYSTEM=="pci", RUN:="${pkgs.bash}/bin/bash -c 'echo 1 | tee /sys/bus/pci/devices/0000:08:00.0/remove'"
  '';

  services.journald.extraConfig = ''
    MaxRetentionSec=1week
  '';
}

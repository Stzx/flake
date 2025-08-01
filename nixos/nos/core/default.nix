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

  services.scx = {
    enable = true;
    package = pkgs.scx.rustscheds;
    scheduler = "scx_bpfland";
  };

  services.udev.extraRules = ''
    ACTION=="add", KERNEL=="0000:08:00.0", SUBSYSTEM=="pci", ATTR{remove}="1"
  '';

  services.journald.extraConfig = ''
    MaxRetentionSec=1week
  '';
}

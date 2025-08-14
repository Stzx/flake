{
  pkgs,
  lib,
  ...
}:

{
  imports = [ ./kernel.nix ];

  zramSwap.enable = true;

  systemd.oomd.enable = false;

  services.scx = {
    enable = true;
    package = pkgs.scx.rustscheds;
    scheduler = "scx_bpfland";
  };

  services.udev.extraRules = ''
    ACTION=="add", KERNEL=="0000:08:00.0", SUBSYSTEM=="pci", ATTR{remove}="1"

    # SET 10% - MAX 20%
    ACTION=="add", KERNEL=="card0", SUBSYSTEM=="drm", RUN+="${lib.getExe pkgs.bash} -c 'echo 333000000 | tee %S%p/device/hwmon/hwmon*/power*_cap'"
  '';

  services.journald.extraConfig = ''
    MaxRetentionSec=1week
  '';
}

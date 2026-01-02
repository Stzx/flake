{
  pkgs,
  lib,
  ...
}:

{
  imports = [ ./kernel.nix ];

  environment.sessionVariables = {
    RADV_PERFTEST = "cswave32,gewave32,pswave32,localbos,sam,nggc";
    # RADV_DEBUG = "startup,info";
  };

  zramSwap.enable = true;

  services.scx.enable = true;

  # ACTION=="add", KERNEL=="0000:08:00.0", SUBSYSTEM=="pci", ATTR{remove}="1"
  # KERNEL=="ttyUSB[0-9]", SUBSYSTEM=="tty", MODE="0666"
  services.udev.extraRules = ''
    # SET 10% - MAX 20%
    ACTION=="add", KERNEL=="card0", SUBSYSTEM=="drm", RUN+="${lib.getExe pkgs.bash} -c 'echo 333000000 | tee %S%p/device/hwmon/hwmon*/power*_cap'"
  '';

  services.journald.extraConfig = ''
    MaxRetentionSec=1week
  '';
}

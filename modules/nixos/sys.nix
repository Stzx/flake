{ config, lib, ... }:

{
  console = {
    font = "LatGrkCyr-8x16";
    earlySetup = true;
  };

  security.apparmor.enable = lib.mkDefault true;

  security.rtkit.enable = lib.mkDefault true;

  services.dbus = {
    enable = true;
    apparmor = if config.security.apparmor.enable then "enabled" else "disabled";
  };
}

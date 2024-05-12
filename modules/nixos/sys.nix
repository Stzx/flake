{ config
, ...
}:

{
  console = {
    font = "LatGrkCyr-8x16";
    earlySetup = true;
  };

  security = {
    apparmor.enable = true;
    rtkit.enable = true;
    sudo.execWheelOnly = true;
  };

  services.irqbalance.enable = true;

  services.dbus = {
    enable = true;
    apparmor = if config.security.apparmor.enable then "enabled" else "disabled";
  };
}

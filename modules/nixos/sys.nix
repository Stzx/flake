{
  config,
  ...
}:

{
  console.font = "LatGrkCyr-8x16";

  security = {
    apparmor.enable = true;
    rtkit.enable = true;
    sudo.execWheelOnly = true;
  };

  services.dbus = {
    enable = true;
    apparmor = if config.security.apparmor.enable then "enabled" else "disabled";
  };
}

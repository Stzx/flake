{
  sys =
    {
      pkgs,
      lib,
      config,
      ...
    }:

    let
      inherit (lib) mkDefault;
    in
    {
      nix = {
        settings.experimental-features = [
          "nix-command"
          "flakes"
        ];
        gc = {
          automatic = true;
          dates = "weekly";
          randomizedDelaySec = "3m";
          options = "--delete-older-than 7d";
        };
      };

      boot = {
        loader = {
          timeout = 1;
          efi.canTouchEfiVariables = true;
          systemd-boot = {
            consoleMode = "max";
            edk2-uefi-shell.enable = true;
          };
        };
        tmp.useTmpfs = mkDefault true;
      };

      documentation.doc.enable = false;

      zramSwap.algorithm = "lzo-rle";

      security = {
        apparmor.enable = true;
        rtkit.enable = true;
        sudo.execWheelOnly = true;
      };

      console.font = mkDefault "LatGrkCyr-8x16";

      systemd.extraConfig = "DefaultTimeoutStopSec=60s";

      users.mutableUsers = mkDefault false;

      time.timeZone = mkDefault "Asia/Shanghai";

      i18n = {
        defaultLocale = "en_US.UTF-8";
        supportedLocales = [
          "C.UTF-8/UTF-8"
          "en_US.UTF-8/UTF-8"
          "zh_CN.UTF-8/UTF-8"
        ];
      };

      services.dbus = {
        enable = true;
        apparmor = if config.security.apparmor.enable then "enabled" else "disabled";
      };

      networking.firewall.extraPackages = with pkgs; [
        bind
        radvd

        nmap
      ];

      environment.shellAliases = rec {
        nm-geo = "sudo nmap -n -sn -Pn --traceroute --script traceroute-geolocation";
        nm-kml = "${nm-geo} --script-args traceroute-geolocation.kmlfile=/tmp/geo.kml";
      };
    };
}

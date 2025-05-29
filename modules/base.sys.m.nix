{
  sys =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    {

      environment.shellAliases = rec {
        nm-geo = "sudo nmap -n -sn -Pn --traceroute --script traceroute-geolocation";
        nm-kml = "${nm-geo} --script-args traceroute-geolocation.kmlfile=/tmp/geo.kml";
      };

      documentation.doc.enable = false;


      i18n = {
        defaultLocale = "en_US.UTF-8";
        supportedLocales = [
          "C.UTF-8/UTF-8"
          "en_US.UTF-8/UTF-8"
          "zh_CN.UTF-8/UTF-8"
        ];
      };


      zramSwap.algorithm = "lzo-rle";

      security = {
        apparmor.enable = true;
        rtkit.enable = true;
        sudo.execWheelOnly = true;
      };

      console.font = lib.mkDefault "LatGrkCyr-8x16";

      services.dbus = {
        enable = true;
        apparmor = if config.security.apparmor.enable then "enabled" else "disabled";
      };

      networking.firewall.extraPackages = with pkgs; [
        bind
        radvd

        nmap
      ];
    };
}

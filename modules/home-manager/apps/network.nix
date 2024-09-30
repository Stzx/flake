{
  pkgs,
  lib,
  config,
  ...
}:

{
  options.programs = {
    net-tools = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
  };

  config = lib.mkIf config.programs.net-tools {
    home.packages = with pkgs; ([ nmap ] ++ lib.my.listNeedWM [ wireshark ]);

    programs.zsh.shellAliases = rec {
      nm-geo = "sudo nmap -n -sn -Pn --traceroute --script traceroute-geolocation";
      nm-kml = "${nm-geo} --script-args traceroute-geolocation.kmlfile=/tmp/geo.kml";
    };
  };
}

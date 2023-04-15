{ config, lib, pkgs, ... }:

{
  options.want.net-tools = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = "Install NetTools";
  };

  config = lib.mkIf config.want.net-tools {
    home.packages = with pkgs; [
      nmap
      wireshark
    ];

    programs.zsh.shellAliases = {
      nmap-geo = "sudo nmap -n -sn -Pn --traceroute --script traceroute-geolocation";
      nmap-kml = "sudo nmap -n -sn -Pn --traceroute --script traceroute-geolocation --script-args traceroute-geolocation.kmlfile=/tmp/geo.kml";
    };
  };
}

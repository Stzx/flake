{ lib, ... }:

let
  gateway = [ "192.168.254.254" ];
in
{
  boot.kernel.sysctl = {
    "net.core.rmem_max" = 16777216;
    "net.core.wmem_max" = 16777216;
    "net.core.netdev_max_backlog" = 8192;
    "net.core.default_qdisc" = "cake";

    "net.ipv4.tcp_rmem" = "4096 87380 16777216";
    "net.ipv4.tcp_wmem" = "4096 65536 16777216";
  };

  environment.etc."gai.conf".text = ''
    precedence ::ffff:0:0/96 100
  '';

  networking = {
    useDHCP = lib.mkForce false;
    nftables.enable = true;
    firewall = {
      enable = true;
      extraInputRules = ''
        ip saddr 192.168.254.0/24 tcp dport 53317 accept
      '';
    };
    nameservers = gateway;
    timeServers = gateway;
  };

  systemd.network = {
    enable = true;
    networks = {
      "20-wan" = rec {
        inherit gateway;

        name = "en*";
        address = [ "192.168.254.253/24" ];
        ntp = gateway;
        networkConfig = {
          DHCP = "ipv6";
          IPv6AcceptRA = true;
        };
        ipv6AcceptRAConfig = {
          UseDNS = false;
        };
      };
    };
    wait-online = {
      anyInterface = true;
      extraArgs = [ "-4" ];
    };
  };

  services = {
    timesyncd.enable = true;
    resolved.enable = lib.mkForce false;
  };
}

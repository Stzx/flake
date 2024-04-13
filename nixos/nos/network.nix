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
  };

  networking = {
    useDHCP = lib.mkForce false;
    nftables.enable = true;
    firewall.enable = true;
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
    resolved.enable = true;
    timesyncd.enable = true;
  };
}

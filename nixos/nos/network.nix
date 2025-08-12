{ lib, ... }:

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

        ip6 daddr ::/0 tcp dport 61611 accept comment "qB"
      '';
    };
  };

  environment.etc."systemd/networkd.conf".enable = lib.mkDefault false;
  systemd.network = {
    enable = true;
    networks = {
      "20-wan" = rec {

        name = "en*";
        address = [ "192.168.254.253/24" ];
        gateway = [ "192.168.254.254" ];
        dns = gateway; # resolved
        ntp = gateway; # timesyncd
        networkConfig = {
          DHCP = "no";
          DNSSEC ="allow-downgrade"; # resolved
          IPv6AcceptRA = true;
          IPv6PrivacyExtensions = true;
        };
      };
    };
    wait-online.anyInterface = true;
  };

  services = {
    timesyncd.enable = true;
    resolved.enable = true;
  };
}

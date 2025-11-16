{ pkgs, lib, ... }:

{
  boot.kernel.sysctl = {
    "net.core.rmem_max" = 16777216;
    "net.core.wmem_max" = 16777216;
    "net.core.netdev_max_backlog" = 8192;
    "net.core.default_qdisc" = "cake";

    "net.ipv4.tcp_rmem" = "4096 87380 16777216";
    "net.ipv4.tcp_wmem" = "4096 65536 16777216";
    "net.ipv4.tcp_mtu_probing" = 1;
  };

  networking = {
    useDHCP = lib.mkForce false;
    useNetworkd = true;
    nftables.enable = true;
    firewall = {
      enable = true;
    };
    getaddrinfo.precedence = {
      "::ffff:0:0/96" = 100;
    };
  };

  environment.etc."systemd/networkd.conf".enable = lib.mkDefault false;
  systemd.network = {
    enable = true;
    networks = {
      "20-wan" = {

        name = "en*";
        networkConfig = {
          DHCP = "ipv4";
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

  programs.wireshark = {
    enable = true;
    package = pkgs.wireshark;
  };
}

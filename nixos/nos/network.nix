{ pkgs, lib, ... }:

{
  boot.kernel.sysctl = {
    "net.core.rmem_max" = 16777216;
    "net.core.wmem_max" = 16777216;
    "net.core.netdev_max_backlog" = 8192;
    "net.core.default_qdisc" = "cake";

    "net.ipv4.tcp_rmem" = "8192 262144 536870912";
    "net.ipv4.tcp_wmem" = "4096 16384 536870912";
    "net.ipv4.tcp_adv_win_scale" = -2;
    "net.ipv4.tcp_notsent_lowat" = 131072;
    "net.ipv4.tcp_collapse_max_bytes" = 6291456; # cloudflare kernel patch
    "net.ipv4.tcp_fastopen" = 3;
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

{
  pkgs,
  lib,
  config,
  ...
}:

let
  inherit (lib) optional;

  wmCfg = config.wm;
in
{
  imports = [
    ./core

    ./fs.nix
    ./audio.nix
    ./network.nix

    ./misc.nix
  ];

  nix.settings.substituters = [
    "https://mirrors.ustc.edu.cn/nix-channels/store"
    "https://mirror.sjtu.edu.cn/nix-channels/store"
    "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
  ];

  nixpkgs.overlays = [
    (import ./overlays.nix { inherit lib wmCfg; })
  ];

  environment.systemPackages = with pkgs; [
    bat

    nmap

    bpftools
    bpftrace
  ];

  environment.shellAliases = rec {
    nm-geo = "sudo nmap -n -sn -Pn --traceroute --script traceroute-geolocation";
    nm-kml = "${nm-geo} --script-args traceroute-geolocation.kmlfile=/tmp/geo.kml";
  };

  features = {
    cpu.amd = true;
    gpu.amd = true;

    THP = true;

    ccache.enable = true;

    wm.enable = "niri";
  };

  users.extraUsers."stzx" = {
    uid = 1000;
    isNormalUser = true; # group = users
    description = "Silece Tai";
    extraGroups = [
      "wheel"
      "input" # waybar, keyboard-state
      "video"
      "audio"
      "dialout"
    ]
    ++ optional config.programs.wireshark.enable "wireshark"
    ++ optional config.virtualisation.docker.enable "docker"
    ++ optional config.virtualisation.libvirtd.enable "libvirtd"
    ++ optional config.programs.adb.enable "adbusers";
  };

  programs.nix-ld.enable = true;

  programs.gnupg.agent = {
    enable = true;
    pinentryPackage = pkgs.pinentry-curses;
  };
}

{
  self,
  pkgs,
  lib,
  config,
  wmCfg,
  ...
}:

let
  inherit (lib) optional;
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
    (import ./overlays.nix { inherit self lib wmCfg; })
  ];

  features = {
    cpu.amd = true;
    gpu.amd = true;

    THP = true;

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
      "wireshark"
    ]
    ++ optional config.virtualisation.docker.enable "docker"
    ++ optional config.virtualisation.libvirtd.enable "libvirtd"
    ++ optional config.programs.adb.enable "adbusers"
    ++ optional config.programs.gamemode.enable "gamemode";
  };

  programs.nix-ld.enable = false;

  programs.gnupg.agent = {
    enable = true;
    pinentryPackage = pkgs.pinentry-curses;
  };

  programs.ccache = {
    enable = true;
    packageNames = [ "linuxManualConfig" ];
  };
}

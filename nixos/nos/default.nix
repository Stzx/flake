{
  self,
  pkgs,
  lib,
  config,
  wmCfg,
  ...
}:

{
  imports = [
    ./core

    ./fs.nix
    ./audio.nix
    ./network.nix
    ./misc.nix
  ];

  nix.settings.substituters = [ "https://mirrors.ustc.edu.cn/nix-channels/store" ];

  nixpkgs.overlays = [
    (import ./overlays.nix { inherit self lib wmCfg; })
  ];

  features = {
    cpu.amd = true;
    gpu.amd = true;

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
    ] ++ lib.optional config.programs.adb.enable "adbusers";
  };

  programs.ccache = {
    enable = true;
    packageNames = [ "mpv-unwrapped" ]; # mainly used to enable ccacheWrapper
  };

  programs.nix-ld.enable = true;

  programs.gnupg.agent = {
    enable = true;
    pinentryPackage = pkgs.pinentry-curses;
  };
}

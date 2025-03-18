{ pkgs, ... }:

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
    (import ./overlays.nix)
  ];

  programs.ccache.packageNames = [ "mpv" ]; # mainly used to enable ccacheWrapper

  features = {
    cpu.amd = true;
    gpu.amd = true;

    wm.niri = true;
  };

  users.extraUsers = {
    "stzx" = {
      uid = 1000;
      isNormalUser = true;
      description = "Silece Tai";
      extraGroups = [
        "wheel"
        "audio"
        "video"

        "keys" # adb-tools
        "wireshark"
      ];
    };
  };

  programs.nix-ld.enable = true;

  programs.gnupg.agent = {
    enable = true;
    pinentryPackage = pkgs.pinentry-curses;
  };
}

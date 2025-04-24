{
  lib,
  config,
  pkgs,
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

  nix.settings.substituters = [ "https://mirrors.ustc.edu.cn/nix-channels/store" ];

  nixpkgs.overlays = [
    (import ./overlays.nix { inherit lib; })
  ];

  features = {
    cpu.amd = true;
    gpu.amd = true;

    wm.niri = true;
  };

  users.extraUsers = {
    "stzx" = {
      uid = 1000;
      isNormalUser = true; # group = users
      description = "Silece Tai";
      extraGroups = [
        "wheel"
        "audio"
        "video"

        "wireshark"
      ] ++ optional config.programs.adb.enable "adbusers";
    };
  };

  programs.ccache.packageNames = [ "mpv-unwrapped" ]; # mainly used to enable ccacheWrapper

  programs.nix-ld.enable = true;

  programs.gnupg.agent = {
    enable = true;
    pinentryPackage = pkgs.pinentry-curses;
  };

  programs.adb.enable = true;

}

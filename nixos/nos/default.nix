{ pkgs, ... }:

{
  imports = [
    ./core

    ./fs.nix
    ./audio.nix
    ./network.nix
    ./misc.nix
  ];

  features = {
    cpu.amd = true;
    gpu.amd = true;
    desktop.kde = true;
  };

  users.extraUsers = {
    "stzx" = {
      uid = 1000;
      isNormalUser = true;
      description = "Silece Tai";
      extraGroups = [ "wheel" "audio" "video" ] ++ [
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

{
  pkgs,
  lib,
  ...
}:

let
  inherit (lib) mkMerge;
in
{
  imports = [
    ../.
    ./mail.nix
    ./misc.nix
  ];

  config = mkMerge [
    {
      home.packages = with pkgs; [
        fuse-archive
        fuse-avfs # original name: avfs
      ];

      programs = {
        ssh.enable = true;

        scrcpy = true;
        net-tools = true;
      };
    }

    (lib.my.attrNeedWM {
      home.packages = with pkgs; [
        calibre
        librecad
        libreoffice

        qbittorrent
        obs-studio
        telegram-desktop
        spotify

        veracrypt
        keepassxc

        jetbrains-toolbox
      ];

      programs = {
        mpv.enable = true;
        rmpc.enable = true;

        zed-editor.enable = true;
      };
    })
  ];
}

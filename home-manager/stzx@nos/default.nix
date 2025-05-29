{
  pkgs,
  lib,
  wmCfg,
  ...
}:

{
  imports = [
    ./mail.nix
    ./misc.nix
  ];

  config = lib.mkMerge [
    {
      home.packages = with pkgs; [
        fuse-archive
        fuse-avfs # original name: avfs
      ];

      programs = {
        ssh.enable = true;
        direnv.enable = true;

        scrcpy = true;
      };
    }

    (lib.mkIf wmCfg.isEnable {
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

{ lib, pkgs, ... }:

{
  imports = [
    ./misc.nix
    ../.
  ] ++ lib.optionals lib.my.isKDE [
    ./kde.nix
  ] ++ lib.optionals lib.my.haveAnyDE [
    ./gtk.nix
    {
      home.packages = with pkgs; [
        calibre
        librecad
        libreoffice

        texlive.combined.scheme-full
        texstudio

        mpv
        nomacs
        obs-studio
        qbittorrent
        telegram-desktop

        veracrypt
        keepassxc

        prismlauncher
      ];
    }
  ];

  want = {
    adb = true;
    net-tools = true;
  };
}

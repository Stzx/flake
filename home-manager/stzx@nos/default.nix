{ pkgs
, lib
, ...
}:

{
  imports = [
    ./user.nix
    ../.
  ] ++ lib.optionals lib.my.isKDE [
    ./kde.nix
  ] ++ lib.listNeedDE [
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
      ];

      programs = {
        firefox.enable = true;
        vscode.enable = true;
      };

      dconf.settings = {
        "org/gnome/desktop/privacy" = {
          remember-recent-files = false;
        };
      };
    }
  ];

  programs = {
    ssh.enable = true;

    adb = true;
    net-tools = true;
  };
}

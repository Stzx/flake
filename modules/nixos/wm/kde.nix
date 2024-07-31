{ pkgs
, lib
, config
, ...
}:

let
  cfg = config.features.wm;
in
{
  options.features.wm.kde = lib.mkOption {
    type = lib.types.bool;
    default = false;
  };

  config = lib.mkIf cfg.kde {
    services = {
      desktopManager.plasma6 = {
        enable = true;
        enableQt5Integration = false;
        notoPackage = pkgs.emptyDirectory;
      };
      greetd = {
        enable = true;
        settings.default_session.command = "${pkgs.greetd.tuigreet}/bin/tuigreet --cmd startplasma-wayland";
      };
      pipewire = {
        enable = true;
        pulse.enable = true;
      };
    };

    environment.plasma6.excludePackages = with pkgs.kdePackages; [
      plasma-browser-integration
      konsole
      elisa
      gwenview
      okular
      kate
      khelpcenter
      print-manager
      krdp
    ];

    i18n.inputMethod = {
      enable = true;
      type = "fcitx5";
      fcitx5.plasma6Support = true;
    };
  };
}

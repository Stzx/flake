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
    services.desktopManager.plasma6 = {
      enable = true;
      enableQt5Integration = false;
      notoPackage = pkgs.emptyDirectory;
    };

    services.pipewire.pulse.enable = true;

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

    i18n.inputMethod.fcitx5.plasma6Support = true;
  };
}

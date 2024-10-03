{
  pkgs,
  lib,
  config,
  ...
}:

let
  inherit (lib) mkIf mkOption types;

  cfg = config.features.wm;
in
{
  options.features.wm.kde = mkOption {
    type = types.bool;
    default = false;
  };

  config = mkIf cfg.kde {
    services.desktopManager.plasma6 = {
      enable = true;
      enableQt5Integration = false;
      notoPackage = pkgs.emptyDirectory;
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

    i18n.inputMethod.fcitx5.plasma6Support = true;
  };
}

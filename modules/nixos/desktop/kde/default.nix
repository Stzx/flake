{ config, lib, pkgs, ... }:

let
  cfg = config.features.desktop;
in
{
  options.features.desktop.kde = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = "Install KDE Plasma 5 desktop environment";
  };

  config = lib.mkIf cfg.kde {
    services = {
      xserver = {
        enable = true;
        desktopManager.plasma5 = {
          enable = true;
          useQtScaling = true;
        };
      };
      greetd = {
        enable = true;
        vt = config.services.xserver.tty;
        settings = {
          default_session = {
            command = "${pkgs.greetd.tuigreet}/bin/tuigreet --cmd startplasma-wayland";
          };
        };
      };
      pipewire = {
        enable = true;
        alsa.enable = true;
        pulse.enable = true;
      };
    };

    # FIXME: https://github.com/NixOS/nixpkgs/issues/248443
    systemd.user.services.plasma-run-with-systemd.wantedBy = lib.mkForce [ "graphical-session-pre.target" ];

    environment.systemPackages = [ pkgs.helvum ];

    environment.plasma5.excludePackages = with pkgs.plasma5Packages; [
      plasma-browser-integration
      konsole
      elisa
      gwenview
      khelpcenter
      print-manager
    ];

    i18n.inputMethod = {
      enabled = "fcitx5";
      fcitx5.addons = [ pkgs.fcitx5-chinese-addons ];
    };

    xdg.portal.xdgOpenUsePortal = true;

    programs.dconf.enable = true;
  };
}

{ pkgs
, lib
, config
, ...
}:

let
  cfg = config.features.wm;
in
{
  options.features.wm.hyprland = lib.mkOption {
    type = lib.types.bool;
    default = false;
  };

  config = lib.mkIf cfg.hyprland {
    services = {
      greetd = {
        enable = true;
        settings.default_session.command = "${pkgs.greetd.tuigreet}/bin/tuigreet --cmd Hyprland";
      };
      pipewire = {
        enable = true;
        pulse.enable = true;
      };
    };

    i18n.inputMethod = {
      enable = true;
      type = "fcitx5";
    };

    programs.hyprland.enable = true;
  };
}

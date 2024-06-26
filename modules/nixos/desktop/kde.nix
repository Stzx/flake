{ pkgs
, lib
, config
, ...
}:

let
  cfg = config.features.desktop;
in
{
  options.features.desktop.kde = lib.mkOption {
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

    environment.systemPackages = [ pkgs.fcitx5-material-color ];

    environment.plasma6.excludePackages = with pkgs.kdePackages; [
      plasma-browser-integration
      konsole
      elisa
      gwenview
      okular
      kate
      khelpcenter
      print-manager
    ];

    xdg.portal.xdgOpenUsePortal = true;

    i18n.inputMethod = {
      enabled = "fcitx5";
      fcitx5 = {
        plasma6Support = true;
        addons = [ pkgs.kdePackages.fcitx5-chinese-addons ];
        settings = {
          inputMethod = {
            "Groups/0" = {
              "Name" = "Default";
              "Default Layout" = "us";
              "DefaultIM" = "shuangpin";
            };
            "Groups/0/Items/0" = {
              "Name" = "keyboard-us";
            };
            "Groups/0/Items/1" = {
              "Name" = "shuangpin";
            };
            "GroupOrder" = {
              "0" = "Default";
            };
          };
          addons = {
            classicui.globalSection = {
              "Vertical Candidate List" = "False";
              "WheelForPaging" = "True";
              "Font" = "Source Han Sans 10";
              "MenuFont" = "Source Han Sans 10";
              "TrayFont" = "Source Han Sans Bold 10";
              "TrayOutlineColor" = "#000000";
              "TrayTextColor" = "#ffffff";
              "PreferTextIcon" = "False";
              "ShowLayoutNameInIcon" = "True";
              "UseInputMethodLanguageToDisplayText" = "True";
              "Theme" = "Material-Color-deepPurple";
              "DarkTheme" = "Material-Color-deepPurple";
              "UseDarkTheme" = "False";
              "UseAccentColor" = "True";
              "PerScreenDPI" = "False";
              "ForceWaylandDPI" = "0";
              "EnableFractionalScale" = "True";
            };
          };
        };
      };
    };
  };
}

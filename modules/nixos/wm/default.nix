{
  pkgs,
  lib,
  ...
}:

let
  inherit (lib)
    mkIf

    isKDE
    isHyprland
    isNiri
    ;
in
{
  imports = [
    ./kde.nix
    ./hyprland.nix
    ./niri.nix
  ];

  config = mkIf lib.my.haveAnyWM {
    environment.systemPackages = [ pkgs.wl-clipboard ];

    xdg.portal.xdgOpenUsePortal = lib.mkDefault true;

    services = {
      greetd.enable = true;
      pipewire = {
        enable = true;
        alsa.enable = true;
        pulse.enable = lib.mkDefault true;
      };
    };

    services.greetd.settings =
      if lib.my.haveAnyWM then
        let
          bin =
            if isKDE then
              "startplasma-wayland"
            else
              (if isHyprland then "Hyprland" else (if isNiri then "niri-session" else null));

          cmd = if (builtins.isNull bin) then "" else " --cmd ${bin}";
        in
        {
          default_session.command = "${pkgs.greetd.tuigreet}/bin/tuigreet${cmd}";
        }
      else
        { };

    fonts = {
      packages = with pkgs; [
        # source-han-serif
        # source-han-sans
        # source-han-mono

        sarasa-gothic
        # Gothic, UI = Inter
        #   Quotes (“”) are full width —— Gothic
        #   Quotes (“”) are narrow —— UI
        #
        # Mono, Term, Fixed = Iosevka
        #   | suffix | half width | ligature |
        #   |--------|:----------:|:--------:|
        #   | Mono   |      N     |     Y    |
        #   | Term   |      Y     |     Y    |
        #   | Fixed  |      Y     |     N    |
        #
        #   Em dashes (——) are full width —— Mono
        #   Em dashes (——) are half width —— Term
        #   No ligature, Em dashes (——) are half width —— Fixed
        #
        # Orthography dimension
        #   CL: Classical orthography
        #   SC, TC, J, K, HC: Regional orthography, following Source Han Sans notations.

        noto-fonts-color-emoji

        # nerd-fonts.iosevka-term-slab
        nerd-fonts.comic-shanns-mono
        nerd-fonts.symbols-only
      ];
      fontconfig = {
        enable = true;
        subpixel.rgba = "rgb";
        defaultFonts = lib.mkForce {
          serif = [
            "Sarasa Gothic SC"
            "Sarasa Gothic TC"
            "Sarasa Gothic HC"
            "Sarasa Gothic J"
            "Sarasa Gothic K"
          ];
          sansSerif = [
            "Sarasa UI SC"
            "Sarasa UI TC"
            "Sarasa UI HC"
            "Sarasa UI J"
            "Sarasa UI K"
          ];
          monospace = [
            "Sarasa Mono SC"
            "Sarasa Mono TC"
            "Sarasa Mono HC"
            "Sarasa Mono J"
            "Sarasa Mono K"
          ];
          emoji = [
            "Noto Color Emoji"
          ];
        };
      };
    };

    i18n.inputMethod = {
      enable = true;
      type = "fcitx5";
      fcitx5 = {
        ignoreUserConfig = true;
        waylandFrontend = true;
        addons = [ pkgs.kdePackages.fcitx5-chinese-addons ];
        settings = {
          globalOptions = {
            Hotkey = {
              EnumerateWithTriggerKeys = "True";
              EnumerateForwardKeys = "";
              EnumerateBackwardKeys = "";
              EnumerateSkipFirst = "False";
            };
            "Hotkey/TriggerKeys"."0" = "Control+space";
            "Hotkey/AltTriggerKeys"."0" = "Shift_L";
            "Hotkey/EnumerateGroupForwardKeys"."0" = "Super+space";
            "Hotkey/EnumerateGroupBackwardKeys"."0" = "Shift+Super+space";
            "Hotkey/ActivateKeys"."0" = "Hangul_Hanja";
            "Hotkey/DeactivateKeys"."0" = "Hangul_Romaja";
            "Hotkey/PrevPage"."0" = "Up";
            "Hotkey/NextPage"."0" = "Down";
            "Hotkey/PrevCandidate"."0" = "Shift+Tab";
            "Hotkey/NextCandidate"."0" = "Tab";
            "Hotkey/TogglePreedit"."0" = "Control+Alt+P";
            "Behavior" = {
              ActiveByDefault = "False";
              resetStateWhenFocusIn = "No";
              ShareInputState = "No";
              PreeditEnabledByDefault = "True";
              ShowInputMethodInformation = "True";
              showInputMethodInformationWhenFocusIn = "False";
              CompactInputMethodInformation = "True";
              ShowFirstInputMethodInformation = "True";
              DefaultPageSize = "5";
              OverrideXkbOption = "False";
              CustomXkbOption = "";
              EnabledAddons = "";
              PreloadInputMethod = "True";
              AllowInputMethodForPassword = "False";
              ShowPreeditForPassword = "False";
              AutoSavePeriod = "30";
            };
            "Behavior/DisabledAddons" = {
              "0" = "chttrans";
              "1" = "cloudpinyin";
              "2" = "fcitx4frontend";
              "3" = "kimpanel";
              "4" = "quickphrase";
              "5" = "spell";
              "6" = "table";
            };
          };
          inputMethod = {
            "Groups/0" = {
              "Name" = "Default";
              "Default Layout" = "us";
              "DefaultIM" = "shuangpin";
            };
            "Groups/0/Items/0"."Name" = "keyboard-us";
            "Groups/0/Items/1"."Name" = "shuangpin";
            "GroupOrder"."0" = "Default";
          };
          addons = {
            classicui.globalSection = {
              "Vertical Candidate List" = "False";
              "WheelForPaging" = "True";
              "Font" = "Sarasa Term Slab SC 10";
              "MenuFont" = "Sarasa UI SC 10";
              "TrayFont" = "Sarasa UI SC Bold 10";
              "TrayOutlineColor" = "#000000";
              "TrayTextColor" = "#ffffff";
              "PreferTextIcon" = "False";
              "ShowLayoutNameInIcon" = "True";
              "UseInputMethodLanguageToDisplayText" = "True";
              "Theme" = "Material-Color-deepPurple";
              "DarkTheme" = "Material-Color-indigo";
              "UseDarkTheme" = "False";
              "UseAccentColor" = "True";
              "PerScreenDPI" = "False";
              "ForceWaylandDPI" = "0";
              "EnableFractionalScale" = "True";
            };
            pinyin = {
              globalSection = {
                "ShuangpinProfile" = "Ziranma";
                "ShowShuangpinMode" = "True";
                "PageSize" = "7";
                "SpellEnabled" = "False";
                "SymbolsEnabled" = "True";
                "ChaiziEnabled" = "True";
                "ExtBEnabled" = "True";
                "CloudPinyinEnabled" = "False";
                "CloudPinyinIndex" = "2";
                "CloudPinyinAnimation" = "True";
                "KeepCloudPinyinPlaceHolder" = "False";
                "PreeditMode" = "Composing pinyin";
                "PreeditCursorPositionAtBeginning" = "True";
                "PinyinInPreedit" = "False";
                "Prediction" = "False";
                "PredictionSize" = "49";
                "SwitchInputMethodBehavior" = "Commit current preedit";
                "UseKeypadAsSelection" = "False";
                "BackSpaceToUnselect" = "True";
                "Number of sentence" = "2";
                "LongWordLengthLimit" = "4";
                "VAsQuickphrase" = "False";
                "FirstRun" = "False";
              };
              sections = {
                ForgetWord."0" = "Control+7";
                PrevPage = {
                  "0" = "minus";
                  "1" = "Up";
                  "2" = "KP_Up";
                  "3" = "Page_Up";
                };
                NextPage = {
                  "0" = "equal";
                  "1" = "Down";
                  "2" = "KP_Down";
                  "3" = "Next";
                };
                PrevCandidate."0" = "Shift+Tab";
                NextCandidate."0" = "Tab";
                CurrentCandidate = {
                  "0" = "space";
                  "1" = "KP_Space";
                };
                CommitRawInput = {
                  "0" = "Return";
                  "1" = "KP_Enter";
                  "2" = "Control+Return";
                  "3" = "Control+KP_Enter";
                  "4" = "Shift+Return";
                  "5" = "Shift+KP_Enter";
                  "6" = "Control+Shift+Return";
                  "7" = "Control+Shift+KP_Enter";
                };
                ChooseCharFromPhrase = {
                  "0" = "bracketleft";
                  "1" = "bracketright";
                };
                FilterByStroke."0" = "grave";
                Fuzzy = {
                  VE_UE = "True";
                  NG_GN = "True";
                  Inner = "True";
                  InnerShort = "True";
                  PartialFinal = "True";
                };
              };
            };
          };
        };
      };
    };
  };
}

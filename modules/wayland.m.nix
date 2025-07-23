{
  sys =
    {
      pkgs,
      lib,
      config,
      wmCfg,
      ...
    }:

    let
      inherit (lib) mkIf mkDefault;
    in
    {
      options.features.wm = {
        enable = lib.mkOption {
          type =
            with lib.types;
            nullOr (enum [
              "kde"
              "niri"
            ]);
          default = null;
        };
      };

      config = mkIf wmCfg.isEnable (
        lib.mkMerge [
          {
            environment.systemPackages = [ pkgs.wl-clipboard ];

            xdg.portal.xdgOpenUsePortal = mkDefault true;

            fonts = {
              enableDefaultPackages = false;
              packages = with pkgs; [
                # source-han-serif
                # source-han-sans
                # source-han-mono

                monaspace
                comic-mono
                # victor-mono

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

                # noto-fonts-cjk-serif
                # noto-fonts-cjk-sans
                noto-fonts-color-emoji

                nerd-fonts.symbols-only
              ];
              fontconfig = {
                enable = true;
                subpixel.rgba = "rgb";
                defaultFonts = lib.mkForce {
                  serif = [
                    "Sarasa Fixed Slab SC"
                    "Sarasa Fixed Slab TC"
                    "Sarasa Fixed Slab HC"
                    "Sarasa Fixed Slab J"
                    "Sarasa Fixed Slab K"
                  ];
                  sansSerif = [
                    "Sarasa Fixed SC"
                    "Sarasa Fixed TC"
                    "Sarasa Fixed HC"
                    "Sarasa Fixed J"
                    "Sarasa Fixed K"
                  ];
                  monospace = [
                    "Sarasa Mono SC"
                    "Sarasa Mono TC"
                    "Sarasa Mono HC"
                    "Sarasa Mono J"
                    "Sarasa Mono K"
                  ];
                  emoji = [ "Noto Color Emoji" ];
                };
              };
            };

            programs.dconf.enable = lib.mkOverride 999 true;

            services.pipewire = {
              enable = true;
              alsa.enable = true;
              pulse.enable = mkDefault true;
            };

            services.greetd =
              let
                exe = wmCfg.getExe;

                args = if (exe == null) then "" else " --cmd ${exe}";
              in
              {
                enable = true;
                settings = {
                  default_session.command = "${lib.getExe pkgs.greetd.tuigreet}${args}";
                };
              };

            i18n.inputMethod = {
              enable = true;
              type = "fcitx5";
              fcitx5 = {
                ignoreUserConfig = true;
                waylandFrontend = true;
                plasma6Support = true;
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
                      "Font" = "Sarasa UI SC 10";
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
          }

          (mkIf (wmCfg.isNiri) (
            let
              file = "xdg-desktop-portal/${wmCfg.enable}-portals.conf";
            in
            {
              xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];

              # https://man.archlinux.org/man/portals.conf.5
              #
              # Due to the configuration loading priority issue with xdg-desktop-portal,
              # niri built-in configuration gets skipped.
              # Additionally, since nixpkgs cannot read INI files and convert them into Attrs,
              # I resorted to hard-coding.
              environment.etc."xdg/${file}".text = ''
                ${builtins.readFile "${config.programs.${wmCfg.enable}.package}/share/${file}"}
                org.freedesktop.impl.portal.FileChooser=gtk;
              '';
            }
          ))
        ]
      );
    };

  home =
    {
      pkgs,
      lib,
      config,
      sysCfg,
      wmCfg,
      ...
    }:

    let
      inherit (lib)
        mkIf
        mkDefault
        ;

      cursor = {
        package = pkgs.capitaine-cursors; # bibata-cursors, material-cursors
        name = "capitaine-cursors-white"; # Bibata-Modern-Ice
        size = 24;
      };
    in
    {
      config = lib.mkMerge [
        (mkIf wmCfg.isEnable {
          home.packages = [ pkgs.fcitx5-material-color ];

          # FIX: https://github.com/nix-community/home-manager/pull/7045
          fonts.fontconfig.enable = !sysCfg.fonts.fontconfig.enable;

          dconf.settings = {
            "org/gnome/desktop/privacy" = {
              remember-app-usage = false;
              remember-recent-files = false;
            };
            "org/gnome/desktop/interface" = {
              color-scheme = "prefer-dark";
            };
          };

          home.pointerCursor = {
            gtk.enable = true;
          }
          // cursor;

          gtk = {
            enable = true;
            theme = {
              package = pkgs.fluent-gtk-theme;
              name = "Fluent-purple-Dark";
            };
            iconTheme = {
              package = pkgs.papirus-icon-theme;
              name = "Papirus-Dark";
            };
          };

          qt = {
            enable = true;
            platformTheme.name = "gtk3";
          };

          programs.kitty.enable = mkDefault true;

          programs.firefox.enable = mkDefault true;
        })

        (mkIf (wmCfg.isNiri) {
          services.playerctld.enable = true;

          systemd.user.services.playerctld.Service.StandardOutput = "file:%t/playerctld.log";

          services.swayidle.enable = true;

          # notifications
          services.mako = {
            enable = true;
            settings = {
              default-timeout = 5000;
              group-by = "app-name,summary";

              icon-path = "${pkgs.papirus-icon-theme}/share/icons/${config.gtk.iconTheme.name}";

              outer-margin = 3;

              font = "Sarasa Fixed Slab SC Italic 13px";
              border-color = "#884DFFFF";
              background-color = "#00000080";

              icon-location = "right";
              text-alignment = "right";
            };
          };

          # launcher
          programs.fuzzel = {
            enable = true;
            settings = {
              main = {
                font = "Monaspace Radon Frozen";
                icon-theme = config.gtk.iconTheme.name;
                horizontal-pad = 8;
                vertical-pad = 16;

                lines = 12;
                tabs = 4;
              };
              colors = rec {
                background = "161b22cc";
                text = "f5f5f5ff";
                selection = "30563fcc";
                selection-text = "3fb950ff";

                match = "c38000ff";
                selection-match = match;

                border = "0088ffff";
              };
              border.radius = 0;
            };
          };

          # launcher
          programs.tofi.settings = {
            font = "Sarasa Fixed Slab SC";
            font-size = 13;

            outline-width = 0;

            background-color = "#1B1D1EBF";

            border-width = 2;
            border-color = "#884DFF";

            history = false;
          };

          programs.waybar.enable = mkDefault true;
        })

        (mkIf wmCfg.isNiri {
          programs.niri.settings.cursor = {
            theme = cursor.name;
            size = cursor.size;
          };
        })
      ];
    };
}

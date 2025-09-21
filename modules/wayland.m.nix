{
  sys =
    {
      pkgs,
      lib,
      config,
      dots,
      ...
    }:

    let
      inherit (lib)
        types

        mkOption
        mkIf
        mkDefault
        mkForce
        ;

      wmCfg = config.wm;

      concatStrings = lib.concatMapStringsSep "\n";

      fontMatch =
        lang: family: fonts:

        if (fonts != [ ]) then
          ''
            <match>
            <test name="lang"><string>${lang}</string></test>
            <test name="family"><string>${family}</string></test>
              <edit name="family" mode="prepend" binding="same">
            ${concatStrings (f: "<string>${f}</string>") fonts}
              </edit>
            </match>
          ''
        else
          "";

      matchesByLang =
        lang: sansSerif: serif: mono:

        lib.concatStrings [
          (fontMatch lang "sans-serif" sansSerif)
          (fontMatch lang "serif" serif)
          (fontMatch lang "monospace" mono)
        ];

      condOption =
        value:
        mkOption {
          type = types.bool;
          default = config.features.wm.enable == value;
          readOnly = true;
        };
    in
    {
      options = {
        features.wm = {
          enable = mkOption {
            type = types.nullOr (
              types.enum [
                "kde"
                "niri"
              ]
            );
            default = null;
          };
        };
        wm = {
          enable = mkOption {
            type = types.bool;
            default = config.features.wm.enable != null;
            readOnly = true;
          };
          exe = mkOption {
            type = types.nullOr types.str;
            default =
              with config.wm;
              if isKDE then
                "startplasma-wayland"
              else if isNiri then
                "niri-session"
              else
                null;
            readOnly = true;
          };
          isKDE = condOption "kde";
          isNiri = condOption "niri";
        };
      };

      config = mkIf config.wm.enable (
        lib.mkMerge [
          {
            xdg.portal.xdgOpenUsePortal = mkDefault true;

            fonts = {
              enableDefaultPackages = false;
              packages = with pkgs; [
                # source-han-serif
                # source-han-sans
                # source-han-mono

                monaspace
                # comic-mono
                # victor-mono
                maple-mono.CN-unhinted

                # lxgw-wenkai
                # lxgw-wenkai-tc

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
                sarasa-gothic

                # noto-fonts-cjk-serif
                # noto-fonts-cjk-sans
                noto-fonts-color-emoji

                nerd-fonts.symbols-only
              ];
              fontconfig = {
                enable = true;
                includeUserConf = mkDefault false;
                defaultFonts = mkForce {
                  sansSerif = [ "Sarasa Gothic SC" ];
                  serif = [ "Sarasa Fixed Slab SC" ];
                  monospace = [ "Sarasa Mono SC" ];
                  emoji = [ "Noto Color Emoji" ];
                };
                localConf = ''
                  <?xml version="1.0" encoding="UTF-8"?>
                  <!DOCTYPE fontconfig SYSTEM "urn:fontconfig:fonts.dtd">
                  <fontconfig>
                  ${matchesByLang "zh-hk" [ "Sarasa Gothic HC" ] [ "Sarasa Fixed Slab HC" ] [ "Sarasa Mono HC" ]}
                  ${matchesByLang "zh-tw" [ "Sarasa Gothic TC" ] [ "Sarasa Fixed Slab TC" ] [ "Sarasa Mono TC" ]}

                  ${matchesByLang "ja" [ "Sarasa Gothic J" ] [ "Sarasa Fixed Slab J" ] [ "Sarasa Mono J" ]}
                  ${matchesByLang "ko" [ "Sarasa Gothic K" ] [ "Sarasa Fixed Slab K" ] [ "Sarasa Mono K" ]}
                  </fontconfig>
                '';
              };
            };

            programs.dconf.enable = lib.mkOverride 999 true;

            services.pipewire = {
              enable = true;
              alsa.enable = true;
              pulse.enable = mkDefault true;
            };

            services.greetd = {
              enable = true;
              settings =
                let
                  exe' = lib.getExe pkgs.tuigreet;
                  exe = wmCfg.exe;

                  args = lib.optionalString (exe != null) " --cmd ${exe}";
                in
                {
                  default_session.command = "${exe'}${args}";
                };
            };

            services.speechd.enable = mkForce false;

            i18n.inputMethod = {
              enable = true;
              type = "fcitx5";
              fcitx5 = {
                waylandFrontend = true;
                ignoreUserConfig = true; # WARN: !!!
                addons = with pkgs; [
                  fcitx5-material-color

                  qt6Packages.fcitx5-chinese-addons
                ];
              };
            };

            environment.etc."xdg/fcitx5".source = dots + "/fcitx5";
          }

          (mkIf (wmCfg.isNiri) {
            xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
          })
        ]
      );
    };

  home =
    {
      pkgs,
      lib,
      config,
      sysCfg,
      ...
    }:

    let
      inherit (lib)
        mkIf
        mkDefault
        ;

      wmCfg = sysCfg.wm;

      cursor = {
        package = pkgs.capitaine-cursors; # bibata-cursors, material-cursors
        name = "capitaine-cursors-white"; # Bibata-Modern-Ice
        size = 24;
      };
    in
    {
      config = lib.mkMerge [
        (mkIf wmCfg.enable {
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
            gtk2.extraConfig = "gtk-im-module = \"fcitx\"";
            gtk3.extraConfig = {
              gtk-im-module = "fcitx";
            };
            gtk4.extraConfig = {
              gtk-im-module = "fcitx";
            };
          };

          qt = {
            enable = true;
            platformTheme.name = "gtk3";
          };

          programs.wezterm.enable = mkDefault true;

          programs.firefox.enable = mkDefault true;

          services.playerctld.enable = true;

          systemd.user.services.playerctld.Service.StandardOutput = "file:%t/playerctld.log";
        })

        (mkIf (config.programs.quickshell.mode == "supplemental" && wmCfg.isNiri) {
          services.swayidle = {
            enable = true;
            timeouts = [
              {
                timeout = 600;
                command = "${pkgs.systemd}/bin/systemctl suspend";
              }
            ];
          };

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
                prompt = "'!!! '";

                line-height = 24;
                vertical-pad = 16;
                horizontal-pad = 32;
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

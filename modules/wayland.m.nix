{
  sys =
    {
      pkgs,
      lib,
      config,
      wmCfg,
      dots,
      ...
    }:

    let
      inherit (lib) mkIf mkDefault mkForce;
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
                defaultFonts = mkForce {
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

            services.greetd = {
              enable = true;
              settings =
                let
                  exe' = lib.getExe pkgs.greetd.tuigreet;
                  exe = wmCfg.getExe;

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
                plasma6Support = true;
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

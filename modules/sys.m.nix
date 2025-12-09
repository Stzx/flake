{
  sys =
    {
      pkgs,
      lib,
      config,
      ...
    }:

    let
      inherit (lib) mkIf mkDefault;

      cfg = config.features;
    in
    {
      options.features = {
        THP = lib.mkEnableOption "Transparent Huge Page";
      };

      config = lib.mkMerge [
        {
          nix = {
            channel.enable = mkDefault false;
            settings = {
              auto-optimise-store = true;
              experimental-features = [
                # "pipe-operators"
                "nix-command"
                "flakes"
              ];
            };
            gc = {
              automatic = true;
              dates = "weekly";
              randomizedDelaySec = "3m";
              options = "--delete-older-than 7d";
            };
          };

          boot = {
            loader = {
              timeout = 1;
              efi.canTouchEfiVariables = true;
              systemd-boot = {
                consoleMode = "max";
                memtest86.enable = mkDefault true;
                edk2-uefi-shell.enable = true;
              };
            };
            tmp.useTmpfs = mkDefault true;
          };

          security = {
            # non-systemd (tty, ...)
            pam.loginLimits = [
              {
                domain = "@nixbld";
                item = "nofile";
                type = "soft";
                value = "4096";
              }
            ];
            apparmor.enable = true;
            sudo.execWheelOnly = true;
            rtkit.enable = true;
          };

          # FIXME: setfont: ERROR kdfontop.c:212 put_font_kdfontop: Unable to load such font with such kernel version
          console = {
            font = mkDefault "LatGrkCyr-8x16";
            earlySetup = mkDefault true;
          };

          systemd.settings.Manager = {
            DefaultTimeoutStopSec = "60s";
            DefaultLimitNOFILE = "4096:524288";
          };

          systemd.user.extraConfig = ''
            DefaultLimitNOFILE=8192:524288
          '';

          users.mutableUsers = mkDefault false;

          time.timeZone = mkDefault "Asia/Shanghai";

          i18n = {
            defaultLocale = "en_US.UTF-8";
            extraLocaleSettings = rec {
              LC_TIME = "zh_CN.UTF-8";
              LC_COLLATE = LC_TIME;
              LC_PAPER = LC_TIME;
            };
            extraLocales = [
              "C.UTF-8/UTF-8"
              "en_US.UTF-8/UTF-8"
              "zh_CN.UTF-8/UTF-8"
            ];
          };

          services.dbus = {
            enable = true;
            apparmor = if config.security.apparmor.enable then "enabled" else "disabled";
          };

          documentation.doc.enable = false;

          programs.nh.enable = true;
        }

        (mkIf cfg.THP {
          boot.tmp.tmpfsHugeMemoryPages = "within_size";

          systemd.tmpfiles.rules = [
            "w /sys/kernel/mm/transparent_hugepage/enabled - - - - madvise"
            "w /sys/kernel/mm/transparent_hugepage/shmem_enabled - - - - within_size"
          ];
        })

        (mkIf config.zramSwap.enable {
          boot.kernel.sysctl = {
            "vm.swappiness" = 180;
            "vm.watermark_boost_factor" = 0;
            "vm.watermark_scale_factor" = 125;
            "vm.page-cluster" = 0;
          };
        })
      ];
    };

  home =
    { sysCfg, ... }:

    {
      # Standalone installation only !!!
      #
      # Set `LOCALE_ARCHIVE_*` to point to the same
      # glibc-locales as the system `LOCALE_ARCHIVE`
      i18n.glibcLocales = sysCfg.i18n.glibcLocales;
    };
}

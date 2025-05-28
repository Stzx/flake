{
  config,
  pkgs,
  lib,
  ...
}:

{
  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      extra-sandbox-paths = [ config.programs.ccache.cacheDir ];
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
        edk2-uefi-shell.enable = true;
      };
    };
    tmp.useTmpfs = true;
  };

  i18n = {
    defaultLocale = "en_US.UTF-8";
    supportedLocales = [
      "C.UTF-8/UTF-8"
      "en_US.UTF-8/UTF-8"
      "zh_CN.UTF-8/UTF-8"
    ];
  };

  time.timeZone = lib.mkDefault "Asia/Shanghai";

  users.mutableUsers = lib.mkDefault false;

  systemd.extraConfig = "DefaultTimeoutStopSec=60s";

  networking.firewall.extraPackages = with pkgs; [
    bind
    radvd
  ];

  documentation.doc.enable = false;

  environment.systemPackages = with pkgs; [
    nix-output-monitor

    smartmontools
    acpitool
    nvme-cli
    pciutils
    usbutils

    lsof
    tree
    file

    bat
    btop
    _7zz
  ];

  programs.ccache.enable = true;

  programs.dconf.enable = lib.mkOverride 999 lib.my.haveAnyWM;

  programs.htop = {
    enable = true;
    settings = {
      hide_userland_threads = true;
      show_thread_names = true;
      show_merged_command = true;
      shadow_other_users = true;
      highlight_base_name = true;
      highlight_threads = true;
      highlight_changes = true;
      tree_view = true;
      tree_view_always_by_pid = true;
    };
  };
}

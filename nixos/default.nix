{ pkgs
, lib
, config
, ...
}:

{
  nix = {
    settings.substituters = [ "https://mirrors.ustc.edu.cn/nix-channels/store" ];
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
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
      systemd-boot.consoleMode = "max";
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

  environment = {
    systemPackages = with pkgs; [
      smartmontools
      acpitool
      nvme-cli
      pciutils
      usbutils

      lsof
      tree
      file

      bat
      p7zip
    ];
    shellAliases =
      let
        _flake = name: "--flake \"$_FLAKE?submodules=1#${name}\"";

        flake = _flake config.networking.hostName;

        userFlake = _flake "$USER@${config.networking.hostName}";
      in
      {
        npdc = "nix profile diff-closures --profile /nix/var/nix/profiles/system";

        rb = "sudo nixos-rebuild boot ${flake} -v";

        rs = "sudo nixos-rebuild switch ${flake} -v";

        rh = "home-manager switch ${userFlake} -v";

        ih = "nix run home-manager -- switch ${userFlake}";

        less = "less -S";
      };
  };

  environment.etc."gai.conf".text = ''
    precedence ::ffff:0:0/96 100
  '';

  programs.git.enable = true;

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

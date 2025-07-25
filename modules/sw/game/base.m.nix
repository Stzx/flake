{
  sys =
    {
      pkgs,
      lib,
      config,
      ...
    }:

    {
      config = lib.mkIf config.services.flatpak.enable {
        services.udev.extraRules = ''
          KERNEL=="ntsync", SUBSYSTEM=="misc", MODE="0666"
        '';

        # 真的很无语，自定义了配置，你还惦记 /share/gamemode/gamemode.ini 这玩意干啥??
        programs.gamemode = {
          enable = false;
          settings = {
            general = {
              renice = 11;
            };

            gpu = {
              amd_performance_level = "high";
            };
          };
        };

        programs.java = {
          enable = lib.mkDefault true;
          package = pkgs.temurin-bin;
          binfmt = true;
        };
      };
    };
}

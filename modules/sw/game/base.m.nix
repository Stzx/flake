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

        programs.java = {
          enable = lib.mkDefault true;
          package = pkgs.temurin-jre-bin;
        };
      };
    };
}

{
  sys =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    {
      services.udev.extraRules = ''
        SUBSYSTEM=="misc", KERNEL=="ntsync", MODE="0666"
      '';

      programs.java = {
        enable = lib.mkDefault config.services.flatpak.enable;
        package = pkgs.temurin-jre-bin;
        binfmt = true;
      };
    };

  home =
    {
      pkgs,
      lib,
      sysCfg,
      ...
    }:

    # GAME
    # ? org.freedesktop.Platform.VulkanLayer.gamescope
    # org.freedesktop.Platform.VulkanLayer.MangoHud
    #
    # com.valvesoftware.Steam
    # com.valvesoftware.Steam.CompatibilityTool.Proton-GE
    #
    # org.prismlauncher.PrismLauncher
    #
    # flatpak override --user --env=PRISMLAUNCHER_JAVA_PATHS=$JAVA_HOME/bin/java --filesystem=/nix/store:ro org.prismlauncher.PrismLauncher
    # ? https://github.com/PrismLauncher/PrismLauncher/blob/af73cfa20f5551ad6ffc5d64379490cd55f87ac6/launcher/java/JavaUtils.cpp#L158
    # https://github.com/BoyOrigin/glfw-wayland
    {
      config = lib.mkIf sysCfg.services.flatpak.enable {
        xdg.dataFile = {
          # flatpak override --user \
          # --env=PROTON_USE_WAYLAND=1 \
          # --env=PROTON_USE_NTSYNC=1 \
          # --env=MANGOHUD=1 \
          # --filesystem=/nix/store:ro \
          # --filesystem=xdg-config/MangoHud:ro \
          # com.valvesoftware.Steam
          "flatpak/overrides/com.valvesoftware.Steam".text = ''
            [Context]
            filesystems=/nix/store:ro;xdg-config/MangoHud:ro;

            [Environment]
            PROTON_USE_WAYLAND=1
            PROTON_USE_NTSYNC=1
            MANGOHUD=1
          '';
        };
      };
    };
}

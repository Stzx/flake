{
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
    #
    # :< If passing the JRE, this issue needs to be fixed:
    # https://github.com/PrismLauncher/PrismLauncher/blob/af73cfa20f5551ad6ffc5d64379490cd55f87ac6/launcher/java/JavaUtils.cpp#L158
    # https://github.com/NixOS/nixpkgs/blob/6e987485eb2c77e5dcc5af4e3c70843711ef9251/pkgs/by-name/pr/prismlauncher/package.nix#L79-L107
    #
    # https://github.com/BoyOrigin/glfw-wayland

    let
      # To prevent infinite recursion caused by xdg-{config,dataFile} cross-references (
      # The xdg files will be merged into the `home-manager-files` folder
      # ), write directly to the file.
      # :<
      # ~/.config/foo/bar.conf > /nix/store/home-manager-files/.config/foo/bar.conf > /nix/store/foobar.conf
      #
      # > MANGOHUD
      # Use `MANGOHUD_CONFIGFILE` to prevent infinite recursion

      font' = "${pkgs.monaspace}/share/fonts/opentype/MonaspaceRadon-Regular.otf";

      # MangoHud/MangoHud.conf
      mangohud' = pkgs.writeText "MangoHud.conf" ''
        horizontal
        horizontal_stretch=0

        font_file=${font'}

        position=top-center
        background_alpha=0
        text_outline=0
        hud_compact

        engine_short_names

        fps_limit=0,141,97,60
        fps_color_change
        show_fps_limit

        cpu_temp
        cpu_mhz
        cpu_load_change

        gpu_temp
        gpu_power
        gpu_load_change

        frame_timing=0
        # dynamic_frame_timing
        # histogram

        # vsync=1
        # gl_vsync=0

        present_mode
        winesync
        display_server
      '';

      # MangoHud/presets.conf
    in
    {
      config = lib.mkIf sysCfg.services.flatpak.enable {
        xdg.dataFile = {
          # flatpak override --user \
          # --env=PROTON_USE_WAYLAND=1 \
          # --env=MANGOHUD=1 \
          # --filesystem=xdg-config/MangoHud:ro \
          # com.valvesoftware.Steam
          #
          # DXVK_FRAME_RATE / VKD3D_FRAME_RATE
          "flatpak/overrides/com.valvesoftware.Steam".text = ''
            [Context]
            filesystems=${font'}:ro;${mangohud'}:ro;xdg-config/MangoHud:ro;

            [Environment]
            PROTON_USE_WAYLAND=1
            MANGOHUD=1
            MANGOHUD_CONFIGFILE=${mangohud'}
          '';
        };
      };
    };
}

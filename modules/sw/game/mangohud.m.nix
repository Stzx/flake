{
  home =
    {
      pkgs,
      lib,
      sysCfg,
      ...
    }:

    {
      config = lib.mkIf sysCfg.services.flatpak.enable {
        xdg.configFile = {
          "MangoHud/MangoHud.conf".text = ''
            table_columns=4
            background_alpha=0
            font_file=${pkgs.monaspace}/share/fonts/opentype/MonaspaceRadon-Regular.otf

            fps_color_change
            fps_limit=60,97,141,0

            cpu_temp
            cpu_mhz
            cpu_load_change

            gpu_temp
            gpu_power
            gpu_load_change

            dynamic_frame_timing
            # histogram

            present_mode
            winesync

            display_server
          '';
        };
        # "MangoHud/presets.conf".text = ''
        # '';
      };
    };
}

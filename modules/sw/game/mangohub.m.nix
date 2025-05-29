{
  home =
    { lib, sysCfg, ... }:
    {
      config = lib.mkIf sysCfg.services.flatpak.enable {
        xdg.configFile."MangoHud/MangoHud.conf".text = ''
          cellpadding_y=0.05

          cpu_load_change
          gpu_load_change

          cpu_temp
          cpu_mhz

          gpu_temp
          gpu_power

          dynamic_frame_timing
          histogram

          engine_short_names
          display_server

          winesync
        '';
      };
    };
}

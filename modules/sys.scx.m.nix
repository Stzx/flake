{
  sys =
    {
      lib,
      config,
      ...
    }:

    let
      cfg = config.services.scx-loader;

      scheds = {
        scx_lavd = {
          auto_mode = [ "--per-cpu-dsq" ];
          gaming_mode = [
            "--performance"
            "--per-cpu-dsq"
          ];
        };
      };
    in
    {
      config = lib.mkIf cfg.enable {
        # https://github.com/sched-ext/scx-loader/blob/main/crates/scx_loader/configuration.md
        services.scx-loader.config = {
          inherit scheds;

          default_sched = "scx_lavd";
          default_mode = "Auto";
        };
      };
    };
}

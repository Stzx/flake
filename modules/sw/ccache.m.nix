{
  sys =
    {
      pkgs,
      lib,
      config,
      ...
    }:

    let
      cfg = config.programs.ccache;
    in
    {
      config = lib.mkIf cfg.enable { nix.settings.extra-sandbox-paths = [ cfg.cacheDir ]; };
    };
}

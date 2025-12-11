{
  sys =
    {
      pkgs,
      lib,
      config,
      ...
    }:

    let
      inherit (lib) mkDefault;

      cfg = config.services.scx;

      args = {
        scx_bpfland = [
          "--local-pcpu"
          "--local-kthreads"
          "--sticky-tasks"
          # "--cpufreq"
        ];

        scx_flash = [
          "--slice-lag-scaling"
          "--local-pcpu"
          "--local-kthreads"
          "--sticky-cpu"
          # "--cpufreq"
        ];
      };
    in
    {
      options = {
        services.scx.userArgs = lib.mkOption {
          type = lib.types.listOf lib.types.singleLineStr;
          default = [ ];
        };
      };

      config = lib.mkIf cfg.enable {
        services.scx = {
          package = mkDefault pkgs.scx.rustscheds;
          scheduler = mkDefault "scx_flash";
          extraArgs = (args."${cfg.scheduler}" or [ ]) ++ cfg.userArgs;
        };
      };
    };
}

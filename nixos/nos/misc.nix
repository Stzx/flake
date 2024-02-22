{
  nix.daemonCPUSchedPolicy = "idle";

  services.pipewire.extraConfig.pipewire = {
    "hw" = {
      "context.properties" = {
        "default.clock.rate" = 48000;
        "default.clock.allowed-rates" = [ 44100 48000 96000 ];
      };
    };
  };

  # for steam
  services.flatpak.enable = true;

  services.boinc.enable = true;

  services.grafana = {
    enable = true;
    settings = {
      analytics = {
        reporting_enabled = false;
        feedback_links_enabled = false;
      };
    };
  };

  virtualisation.docker = {
    enable = true;
    enableOnBoot = false;
  };
}

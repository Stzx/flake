{
  # for game
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

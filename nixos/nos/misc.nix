let
  systemd_user_sessions = [ "systemd-user-sessions.service" ];
in
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
  systemd.services.grafana.after = systemd_user_sessions;
  systemd.services.grafana.requires = systemd_user_sessions;

  virtualisation.docker = {
    enable = true;
    enableOnBoot = false;
  };
  systemd.sockets.docker.after = systemd_user_sessions;
  systemd.sockets.docker.requires = systemd_user_sessions;
}

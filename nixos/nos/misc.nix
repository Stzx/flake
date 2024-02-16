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

  virtualisation.docker = {
    enable = true;
    enableOnBoot = false;
  };
}

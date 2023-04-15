{
  nix.daemonCPUSchedPolicy = "idle";

  virtualisation.docker = {
    enable = true;
    enableOnBoot = false;
  };
}

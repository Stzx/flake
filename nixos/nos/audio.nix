{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    qpwgraph
  ];

  services.pipewire.extraConfig.pipewire = {
    "hw" = {
      "context.properties" = {
        "default.clock.rate" = 48000;
        "default.clock.allowed-rates" = [ 44100 48000 88200 96000 ];
      };
    };
  };
}

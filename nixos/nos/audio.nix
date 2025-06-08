{ ... }:

{
  # qpwgraph, helvum

  services.pipewire.extraConfig.pipewire = {
    "hw" = {
      "context.properties" = {
        "default.clock.rate" = 48000;
        "default.clock.allowed-rates" = [
          44100
          48000
          88200
          96000
          # 192000
        ];
      };
    };
  };

  services.pipewire.wireplumber.extraConfig = {
    "hw" = {
      "wireplumber.profiles" = {
        main = {
          "hardware.bluetooth" = "disabled";
        };
      };
    };
  };
}

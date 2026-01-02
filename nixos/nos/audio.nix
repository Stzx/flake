{ config, ... }:

let
  cfg = config.services.pipewire;
in
{
  services.pipewire = {
    extraConfig = {
      pipewire = {
        "00-virtual-mic-sink" = {
          "context.objects" = [
            {
              factory = "adapter";
              args = {
                "factory.name" = "support.null-audio-sink";

                "node.name" = "virtual-sink";
                "node.description" = "Virtual Sink";
                "node.passive" = true;
                "node.virtual" = true;

                "object.linger" = true;

                "media.class" = "Audio/Sink";

                "audio.position" = [
                  "FL"
                  "FR"
                ];

                "monitor.channel-volumes" = true;
                "monitor.passthrough" = true;
              };
            }
            {
              factory = "adapter";
              args = {
                "factory.name" = "support.null-audio-sink";

                "node.name" = "virtual-mic";
                "node.description" = "Virtual Microphone";
                "node.virtual" = true;

                "object.linger" = true;

                "media.class" = "Audio/Source/Virtual";

                "audio.position" = [
                  "FL"
                  "FR"
                ];
              };
            }
          ];
        };
        "10-virtual-mic-sink-link" = {
          "context.exec" = [
            {
              path = "${cfg.package}/bin/pw-link";
              args = [
                "-w"
                "virtual-sink:monitor_FL"
                "virtual-mic:input_FL"
              ];
            }
            {
              path = "${cfg.package}/bin/pw-link";
              args = [
                "-w"
                "virtual-sink:monitor_FR"
                "virtual-mic:input_FR"
              ];
            }
          ];
        };

        "99-hw" = {
          "context.properties" = {
            "default.clock.rate" = 48000;
            "default.clock.allowed-rates" = [
              44100
              48000
              88200
              96000
              192000
            ];
            "default.clock.quantum" = 256;
            "default.clock.quantum-limit" = 1024;
            "default.clock.min-quantum" = 128;
            "default.clock.max-quantum" = 1024;

            "module.x11.bell" = false;
            "module.jackdbus-detect" = false;
          };
        };
      };
      pipewire-pulse = {
        "99-hw" = {
          "pulse.properties" = {
            "pulse.default.req" = "256/48000";
            "pulse.min.req" = "128/48000";
            "pulse.min.quantum" = "128/48000";
          };
        };
      };
    };
    wireplumber.extraConfig = {
      "99-disabled" = {
        "wireplumber.profiles" = {
          main = {
            "hardware.bluetooth" = "disabled";
            "hardware.video-capture" = "disabled";

            "monitor.alsa-midi" = "disabled";
          };
        };
      };
    };
  };
}

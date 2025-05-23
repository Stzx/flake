{ config, ... }:

let
  cfg = config.services.mpd;
in
{
  services.mpd = {
    enable = config.programs.rmpc.enable;
    network.startWhenNeeded = true; # wait socket or port
    dbFile = "${cfg.dataDir}/tags";
    extraConfig = ''
      auto_update "yes"
      audio_output {
        type "pipewire"
        name "PipeWire Sound Server"
        mixer_type "none"
        replay_gain_handler "none"
      }

      restore_paused "yes"
    '';
  };

  # HM does not have overrideStrategy
  xdg.configFile."systemd/user/mpd.service.d/overrides.conf".text = ''
    [Service]
    ExecStart=
    ExecStart=${
      builtins.replaceStrings [ "--no-daemon" ] [ "--systemd" ]
        config.systemd.user.services.mpd.Service.ExecStart
    }
    LimitRTPRIO=40
    LimitRTTIME=infinity
  '';

  programs.rmpc.config = ''
    #![enable(implicit_some)]
    #![enable(unwrap_newtypes)]
    #![enable(unwrap_variant_newtypes)]
    (
        enable_mouse: false,
        tabs: [
            (
                name: "Queue",
                pane: Split(
                    direction: Horizontal,
                    panes: [(size: "35%", pane: Pane(AlbumArt)), (size: "65%", pane: Pane(Queue))],
                ),
            ),
            (
                name: "Directories",
                pane: Pane(Directories),
            ),
            (
                name: "Artists",
                pane: Pane(Artists),
            ),
            (
                name: "Albums",
                pane: Pane(Albums),
            )
        ],
    )
  '';
}

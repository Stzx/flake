{
  home =
    { lib, config, ... }:
    {
      config = lib.mkIf config.programs.rmpc.enable {
        services.mpd = {
          enable = true;
          network.startWhenNeeded = true; # wait socket or port
          dbFile = "${config.services.mpd.dataDir}/tags";
          extraConfig = ''
            filesystem_charset "UTF-8"
            restore_paused "yes"

            audio_output {
              type "pipewire"
              name "PipeWire Sound Server"
              mixer_type "none"
              replay_gain_handler "none"
            }
          '';
        };

        services.mpdscribble.enable = true;

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

        programs.zsh.shellAliases.rmpc = "rmpc -a $XDG_RUNTIME_DIR/mpd/socket";
      };
    };
}

{
  pkgs,
  lib,
  config,
  osConfig,
  ...
}:

let
  inherit (lib) mkIf mkMerge;

  cfg = config.programs;

  zshCfg = cfg.zsh;
  kittyCfg = cfg.kitty;

  osEnv = osConfig.environment;
in
mkIf zshCfg.enable (mkMerge [
  {
    programs.zsh = {
      envExtra = ''
        ZSH_COMPDUMP="/tmp/.zcompdump-$USER";

        ${osEnv.interactiveShellInit or ""}
      '';
      shellAliases = mkMerge [
        osEnv.shellAliases

        (mkIf kittyCfg.enable {
          icat = "kitty +kitten icat";
          kssh = "kitty +kitten ssh";
        })

        (mkIf cfg.rmpc.enable { rmpc = "rmpc -a $XDG_RUNTIME_DIR/mpd/socket"; })
      ];
      history = {
        ignoreAllDups = true;
        ignorePatterns = [
          "l"
          "ls"
          "rm *"
          "find *"
          "mpv *"
          "vim *"
          "cat *"
          "bat *"
        ];
      };
      autosuggestion = {
        enable = true;
        strategy = [
          "history"
          "completion"
        ];
      };
      syntaxHighlighting = {
        enable = true;
        highlighters = [
          "main"
          "brackets"
          "cursor"
        ];
      };
      oh-my-zsh = {
        enable = true;
        theme = "gentoo";
        plugins = [
          "colored-man-pages"
          "sudo"
          "git"
          "git-flow"
          "rust"
          "flutter"
        ];
      };
    };

    programs.direnv.enableZshIntegration = true;

    programs.vscode.profiles.default.userSettings."terminal.integrated.defaultProfile.linux" = "zsh";
  }

  (mkIf kittyCfg.enable {
    programs.bash.initExtra = ''
      # home manager has checked to see if it is an interactive terminal
      # but it still needs attention
      if [[ -n "$KITTY_PID" ]] && [[ -n "$KITTY_WINDOW_ID" ]]; then
          exec ${pkgs.zsh}/bin/zsh
      fi
    '';
  })
])

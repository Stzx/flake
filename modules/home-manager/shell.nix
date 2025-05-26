{
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
          "cp *"
          "rm *"
          "cat *"
          "grep *"
          "tree *"
          "find *"
          "mpv *"
          "vim *"
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

    programs.zed-editor.userSettings.terminal.shell.program = "zsh";
  }
])

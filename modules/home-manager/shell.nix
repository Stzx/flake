{
  lib,
  config,
  osConfig,
  ...
}:

let
  inherit (lib) mkIf mkMerge optionalAttrs;

  cfg = config.programs;

  zshCfg = cfg.zsh;
  kittyCfg = cfg.kitty;

  osEnv = osConfig.environment;
in
mkMerge [
  (mkIf zshCfg.enable {
    programs.zsh = {
      envExtra = osEnv.interactiveShellInit;
      initExtraFirst = ''
        ZSH_COMPDUMP="/tmp/.zcompdump-$USER"
      '';
      shellAliases =
        osEnv.shellAliases
        // optionalAttrs kittyCfg.enable {
          icat = "kitty +kitten icat";
          kssh = "kitty +kitten ssh";
        };
      history.ignoreAllDups = true;
      autosuggestion = {
        enable = true;
        strategy = [
          "history"
          "completion"
        ];
      };
      syntaxHighlighting.enable = true;
      oh-my-zsh = {
        enable = true;
        theme = "dieter";
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

    programs.vscode.userSettings."terminal.integrated.defaultProfile.linux" = "zsh";
  })
]

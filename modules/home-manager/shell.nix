{
  lib,
  config,
  osConfig,
  ...
}:

let
  inherit (lib) mkIf mkMerge;

  zshCfg = config.programs.zsh;

  osEnv = osConfig.environment;
in
mkMerge [
  (mkIf zshCfg.enable {
    programs.zsh = {
      envExtra = osEnv.interactiveShellInit;
      initExtraFirst = ''
        ZSH_COMPDUMP="/tmp/.zcompdump-$USER"
      '';
      shellAliases = osEnv.shellAliases;
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

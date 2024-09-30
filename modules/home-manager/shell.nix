{
  lib,
  config,
  osConfig,
  ...
}:

let
  osEnv = osConfig.environment;
in
lib.mkIf config.programs.zsh.enable {
  programs.zsh = {
    envExtra = osEnv.interactiveShellInit;
    initExtraFirst = ''
      ZSH_COMPDUMP="/tmp/.zcompdump-$USER"
      ZSH_AUTOSUGGEST_STRATEGY=(history completion)
    '';
    shellAliases = osEnv.shellAliases;
    history.ignoreAllDups = true;
    autosuggestion.enable = true;
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
}

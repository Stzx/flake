{ lib
, config
, osConfig
, ...
}:

let
  cfg = config.programs.zsh;

  osEnv = osConfig.environment;
in
lib.mkIf cfg.enable {
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
      theme = "simonoff";
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

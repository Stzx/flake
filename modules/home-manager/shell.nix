{ lib
, nixos
, config
, ...
}:

let
  cfg = config.programs.zsh;

  osEnv = nixos.environment;
in
lib.mkIf cfg.enable {
  programs.zsh = {
    autosuggestion.enable = true;
    oh-my-zsh = {
      enable = true;
      theme = "simonoff";
      plugins = [
        "zsh-navigation-tools"
        "colored-man-pages"
        "command-not-found"
        "sudo"
        "cp"
        "git"
        "git-flow"
        "rust"
        "flutter"
      ];
    };
    envExtra = ''
      ZSH_COMPDUMP="/tmp/.zcompdump-$USER"
    '';
    initExtra = osEnv.interactiveShellInit;
    shellAliases = osEnv.shellAliases;
  };

  programs.direnv.enableZshIntegration = true;

  programs.vscode.userSettings."terminal.integrated.defaultProfile.linux" = "zsh";
}

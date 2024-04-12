{ nixos, config, lib, ... }:

let
  cfg = config.want;
in
{
  options.want = {
    zsh = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Integrate zsh into the system";
    };
  };

  config = lib.mkIf cfg.zsh {
    programs.direnv.enableZshIntegration = true;

    programs.zsh = {
      enable = true;
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
      initExtra = nixos.environment.interactiveShellInit;
      shellAliases = nixos.environment.shellAliases // {
        man-cn = "man -L zh_CN.UTF-8";
        less = "less -S";
      };
    };
  };
}

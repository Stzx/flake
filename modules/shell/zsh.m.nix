{
  home =
    {
      lib,
      config,
      sysCfg,
      ...
    }:

    let
      cfg = config.programs.zsh;

      sysEnv = sysCfg.environment;
    in
    {
      config = lib.mkIf cfg.enable {
        programs.zsh = {
          envExtra = ''
            ZSH_COMPDUMP="/tmp/.zcompdump-$USER";

            ${sysEnv.interactiveShellInit or ""}
          '';
          shellAliases = sysEnv.shellAliases;
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

        programs.kitty.extraConfig = "shell ${lib.getExe cfg.package}";

        programs.direnv.enableZshIntegration = true;

        programs.vscode.profiles.default.userSettings."terminal.integrated.defaultProfile.linux" = "zsh";

        programs.zed-editor.userSettings.terminal.shell.program = "zsh";
      };
    };
}

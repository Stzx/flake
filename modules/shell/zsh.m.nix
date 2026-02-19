{
  sys =
    { ... }:

    {
      environment.pathsToLink = [ "/share/zsh" ];
    };

  home =
    {
      lib,
      config,
      sysCfg,
      ...
    }:

    let
      cfg = config.programs.zsh;

      exe = lib.getExe cfg.package;

      sysEnv = sysCfg.environment;
    in
    {
      config = lib.mkIf cfg.enable {
        programs.zsh = {
          envExtra = ''
            ${sysEnv.interactiveShellInit or ""}

            ZSH_COMPDUMP="$XDG_RUNTIME_DIR/.zcompdump";
          '';
          shellAliases = sysEnv.shellAliases;
          history = {
            ignoreAllDups = true;
            ignorePatterns = [
              "l *"
              "ls *"
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

        programs = {
          kitty.extraConfig = "shell ${exe}";

          ghostty.settings.command = exe;

          vscode.profiles.default.userSettings."terminal.integrated.defaultProfile.linux" = exe;

          zed-editor.userSettings.terminal.shell.program = exe;
        };
      };
    };
}

{ pkgs, ... }:

{
  programs.vscode = {
    enableExtensionUpdateCheck = false;
    enableUpdateCheck = false;
    extensions = with pkgs.vscode-extensions; [
      pkief.material-icon-theme
      monokai.monokai-pro

      vscodevim.vim

      mkhl.direnv
      twxs.cmake
      timonwong.shellcheck
      jnoortheen.nix-ide

      dart-code.flutter
      dart-code.dart-code

      ms-vscode.cpptools
      ms-vscode.makefile-tools
      ms-vscode.hexeditor

      rust-lang.rust-analyzer
    ];
    userSettings = {
      "extensions.autoUpdate" = false;

      "files.enableTrash" = false;

      "workbench.startupEditor" = "none";
      "workbench.colorTheme" = "Monokai Classic";
      "workbench.iconTheme" = "material-icon-theme";

      "editor.fontFamily" = "'Sarasa Mono SC', 'Sarasa Mono TC', 'Sarasa Mono HC', 'Sarasa Mono J', 'Sarasa Mono K', monospace";
      "editor.fontLigatures" = true;
      "editor.cursorStyle" = "underline";

      "editor.renderWhitespace" = "all";
      "editor.formatOnSave" = true;
      "editor.rulers" = [ 80 ];

      "nix.enableLanguageServer" = true;
      "nix.serverPath" = "nil";
      "nix.serverSettings.nil.formatting.command" = [ "nixpkgs-fmt" ];

      "dart.checkForSdkUpdates" = false;
    };
  };
}

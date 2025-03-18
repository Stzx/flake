{ pkgs, ... }:

let
  inherit (pkgs) mkShell overrideCC clangStdenv;

  # FIXME: https://github.com/NixOS/nixpkgs/issues/49894
  llvmShell = mkShell.override {
    stdenv = overrideCC clangStdenv (
      clangStdenv.cc.override {
        inherit (pkgs.llvmPackages) bintools;
      }
    );
  };
in
{
  default = llvmShell {
    packages = with pkgs; [
      nil
      nixfmt-rfc-style
    ];
  };

  kernel = mkShell {
    packages = with pkgs; [
      dracut

      flex
      bison
    ];

    nativeBuildInputs = [ pkgs.pkg-config ];

    buildInputs = [ pkgs.ncurses ];

    shellHook = ''
      export ARCH="$(uname --machine)" \
      && git fetch origin tag "$(uname --kernel-release)" --depth=1 \
      && git checkout "tags/$(uname --kernel-release)" \
      && (make helpnewconfig | less -F)
    '';
  };
}

{ pkgs, ... }:

let
  inherit (pkgs)
    mkShell
    mkShellNoCC
    ;

  # FIXME: https://github.com/NixOS/nixpkgs/issues/49894
  _llvmShell = mkShell.override {
    stdenv = pkgs.overrideCC pkgs.clangStdenv (
      pkgs.clangStdenv.cc.override {
        inherit (pkgs.llvmPackages) bintools;
      }
    );
  };
in
{
  default = mkShellNoCC {
    packages = with pkgs; [
      nil
      taplo
      nixfmt-rfc-style
    ];
  };

  latex = mkShellNoCC {
    packages = with pkgs; [
      (texliveSmall.withPackages (
        ps: with ps; [
          roboto
          sourcesanspro
          fontawesome5

          ctex
          enumitem
          tcolorbox
          tikzfill
          ifmtarg
          xifthen
          xstring
        ]
      ))
    ];
  };

  kernel = mkShell {
    packages = [ pkgs.dracut ];

    nativeBuildInputs = with pkgs; [
      bison
      flex
      pahole
      rustc
      rust-bindgen

      pkg-config
    ];

    buildInputs = [ pkgs.ncurses ];

    shellHook = ''
      export ARCH="$(uname --machine)" \
      && git fetch origin tag "$(uname --kernel-release)" --depth=1 \
      && git checkout "tags/$(uname --kernel-release)" \
      && (make helpnewconfig | less -F)
    '';
  };
}

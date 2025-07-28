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

  default' = {
    packages = with pkgs; [
      nil
      taplo

      nixfmt
    ];
  };

  proxy' = {
    RUSTUP_DIST_SERVER = "https://mirrors.ustc.edu.cn/rust-static";
    RUSTUP_UPDATE_ROOT = "https://mirrors.ustc.edu.cn/rust-static/rustup";
  };
in
{
  default = mkShellNoCC (default' // proxy');

  noProxy = mkShellNoCC default';

  latex = mkShellNoCC {
    packages = with pkgs; [
      texlab

      (texliveSmall.withPackages (
        ps: with ps; [
          roboto
          sourcesanspro
          fontawesome5
          fandol

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

  media = mkShellNoCC {
    packages = with pkgs; [
      flac
      alac

      exiftool
      mediainfo
    ];
  };

  misc = mkShellNoCC {
    packages = with pkgs; [
      read-edid
      fontpreview

      unrar
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

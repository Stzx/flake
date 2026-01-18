{ pkgs, ... }:

let
  inherit (pkgs)
    mkShell
    mkShellNoCC
    ;

  mkLLVMShell = mkShell.override {
    stdenv = pkgs.overrideCC pkgs.clangStdenv (
      pkgs.clangStdenv.cc.override {
        inherit (pkgs.llvmPackages) bintools;
      }
    );
  };

  default' = {
    packages = with pkgs; [
      nix-init
      nix-diff
      nix-tree

      nil
      taplo

      qt6Packages.qtdeclarative

      nixfmt

      treefmt

      sops
    ];
  };

  mirror' = {
    # RUSTUP_DIST_SERVER = "https://mirrors.cernet.edu.cn/rustup";
    # RUSTUP_UPDATE_ROOT = "https://mirrors.cernet.edu.cn/rustup/rustup";

    # PUB_HOSTED_URL = "https://pub.flutter-io.cn";
    # FLUTTER_STORAGE_BASE_URL = "https://storage.flutter-io.cn";

    NIX_NPM_REGISTRY = "https://r.cnpmjs.org/";
  };
in
{
  default = mkShellNoCC (default' // mirror');

  noProxy = mkShellNoCC default';

  java = mkShellNoCC {
    packages = with pkgs; [
      temurin-bin

      python3
    ];
  };

  wrt = mkShell (
    {
      packages = with pkgs; [
        wget
        unzip
        uftpd
        # minicom # prefer wezterm serial

        binwalk
        ubootTools
        mtk-uartboot

        git

        pkg-config

        (python3.withPackages (ps: [ ps.setuptools ]))

        swig
      ];

      buildInputs = [ pkgs.ncurses ];

      hardeningDisable = [ "all" ];
    }
    // mirror'
  );

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

  kernel = mkLLVMShell {
    packages = with pkgs; [
      git

      dracut
    ];

    nativeBuildInputs = with pkgs; [
      bison
      flex
      pahole
      rustc-unwrapped
      rust-bindgen-unwrapped

      pkg-config
    ];

    buildInputs = [ pkgs.ncurses ];

    shellHook = ''
      export ARCH="$(uname --machine)" \
      && export LLVM=1 \
      && git fetch -v --shallow-exclude=* --depth=1 origin tag "$(uname --kernel-release)" \
      && git checkout "tags/$(uname --kernel-release)" \
      && (make helpnewconfig | less -F)
    '';
  };
}

{ pkgs, ... }:

let
  inherit (pkgs) mkShell;

  llvmShell = mkShell.override {
    stdenv = with pkgs; overrideCC clangStdenv (clangStdenv.cc.override {
      inherit (llvmPackages) bintools;
    });
  };

  nvimPackages = with pkgs; [
    nil
    nixpkgs-fmt

    rustup
  ];
in
{
  default = llvmShell {
    packages = nvimPackages;
  };

  rs = llvmShell {
    packages = with pkgs; [
      cargo-asm
      cargo-bloat
      cargo-cross
      cargo-deps
      cargo-expand

      cargo-wasi
      wit-bindgen
      wasm-tools
    ] ++ nvimPackages;

    nativeBuildInputs = with pkgs; [
      pkg-config

      lld
      lldb
    ];

    buildInputs = with pkgs; [
      pipewire
    ];
  };

  kernel = llvmShell {
    packages = with pkgs; [ flex bison ];

    nativeBuildInputs = with pkgs; [ pkg-config ];

    buildInputs = with pkgs; [ ncurses ];

    shellHook = ''
      _arch="$(uname --machine)"

      echo

      export LLVM=1 && \
      export ARCH=$_arch && \
      git fetch origin tag "$(uname --kernel-release)" --depth=1 && \
      git checkout "tags/$(uname --kernel-release)" && \
      make helpnewconfig | less -F

      echo
    '';
  };
}

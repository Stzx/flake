{ pkgs, ... }:

let
  inherit (pkgs) mkShell;

  llvmShell = mkShell.override { inherit (pkgs.llvmPackages) stdenv; };

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

  kernel = mkShell {
    packages = with pkgs; [ flex bison ];

    nativeBuildInputs = with pkgs; [ pkg-config ];

    buildInputs = with pkgs; [ ncurses ];
  };
}

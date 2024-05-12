{ pkgs, ... }:

let
  inherit (pkgs) mkShell;

  # FIXME: https://github.com/NixOS/nixpkgs/issues/49894
  llvmShell = mkShell.override {
    stdenv = with pkgs; overrideCC clangStdenv (clangStdenv.cc.override {
      inherit (llvmPackages) bintools;
    });
  };
in
{
  default = llvmShell {
    packages = with pkgs; [
      nil
      nixpkgs-fmt
    ];
  };

  kernel = llvmShell {
    packages = with pkgs; [ flex bison ];

    nativeBuildInputs = with pkgs; [ pkg-config ];

    buildInputs = with pkgs; [ ncurses ];

    shellHook = ''
      _arch="$(uname --machine)"

      export LLVM=1 && \
      export ARCH=$_arch && \
      git fetch origin tag "$(uname --kernel-release)" --depth=1 && \
      git checkout "tags/$(uname --kernel-release)" && \
      (make helpnewconfig | less -F)
    '';
  };
}

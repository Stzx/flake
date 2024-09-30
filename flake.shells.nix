{ pkgs, ... }:

let
  # FIXME: https://github.com/NixOS/nixpkgs/issues/49894
  llvmShell = (
    with pkgs;

    mkShell.override {
      stdenv = overrideCC clangStdenv (
        clangStdenv.cc.override {
          inherit (llvmPackages) bintools;
        }
      );
    }
  );
in
{
  default = llvmShell {
    packages = with pkgs; [
      nil
      nixfmt-rfc-style
    ];
  };

  kernel = llvmShell {
    packages = with pkgs; [
      flex
      bison
    ];

    nativeBuildInputs = [ pkgs.pkg-config ];

    buildInputs = [ pkgs.ncurses ];

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

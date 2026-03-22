{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

# https://github.com/xtaci/kcptun/tree/v20260314
# This project is archived and no longer maintained.
buildGoModule (finalAttrs: rec {
  pname = "kcptun";
  version = "20260314";

  src = fetchFromGitHub {
    owner = "xtaci";
    repo = "kcptun";
    rev = "v${version}";
    hash = "sha256-vTJwB+2YOCxqvN9qjjGhfwCbxlLPzSW3kTvlaeFvOMk=";
  };

  vendorHash = null;

  ldflags = [
    "-s"
    "-w"
  ];

  meta = {
    description = "A Quantum-Safe Secure Tunnel based on QPP, KCP, FEC, and N:M multiplexing";
    homepage = "https://github.com/xtaci/kcptun";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
})

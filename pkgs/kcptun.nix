{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule (finalAttrs: rec {
  pname = "kcptun";
  version = "20251212";

  src = fetchFromGitHub {
    owner = "xtaci";
    repo = "kcptun";
    rev = "v${version}";
    hash = "sha256-vJ6o6OlyYHLow4utoGIvyORZE5Te0vC6OPA3o9EuAl8=";
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

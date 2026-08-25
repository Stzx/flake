{
  lib,
  stdenvNoCC,
  fetchurl,
  _7zz,
  installFonts,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "sarasa-gothic-unhinted";
  version = "1.0.41";

  src = fetchurl {
    url = "https://github.com/be5invis/Sarasa-Gothic/releases/download/v${finalAttrs.version}/Sarasa-TTC-Unhinted-${finalAttrs.version}.7z";
    hash = "sha256-poWhiDd3gjZ0x/IrRbXFP1bEG8s2Qpx8XfabEgC1oFU=";
  };

  sourceRoot = ".";

  nativeBuildInputs = [
    _7zz
    installFonts
  ];

  unpackPhase = ''
    runHook preUnpack

    7zz x $src

    runHook postUnpack
  '';

  meta = {
    description = "CJK programming font based on Iosevka and Source Han Sans";
    homepage = "https://github.com/be5invis/Sarasa-Gothic";
    license = lib.licenses.ofl;
    maintainers = [ ];
    platforms = lib.platforms.all;
  };
})

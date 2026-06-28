{
  lib,
  stdenvNoCC,
  fetchurl,
  buildDotnetModule,
  fetchFromGitHub,
  dotnetCorePackages,
  wrapGAppsHook3,
  gtk3,
  libnotify,
}:
let
  liboodle-so = stdenvNoCC.mkDerivation (finalAttrs: {
    pname = "liboodle-so";
    version = "2.9.16";

    src = fetchurl (
      let
        repo = "https://github.com/WorkingRobot/OodleUE";
        rev = "b8e4f109e400588655f81368c68f2c0efcadfa6a";
      in
      {
        url = "${repo}/raw/${rev}/Engine/Source/Runtime/OodleDataCompression/Sdks/${finalAttrs.version}/lib/Linux/liboo2corelinux64.so.9";
        hash = "sha256-GBpWEs+/9jCQvMx5SzKPY7hrTWKnGj1U9v20kfh+JN8=";
      }
    );

    dontUnpack = true;

    installPhase = ''
      mkdir -p $out
      cp -r $src $out/liboo2core.so
    '';
  });
in
buildDotnetModule (finalAttrs: {
  pname = "visual-ggpk3";
  version = "2.7.5";

  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromGitHub {
    owner = "aianlinb";
    repo = "LibGGPK3";
    tag = "v${finalAttrs.version}";
    hash = "sha256-pjsqLZiyNWga0QYbxcBZCZFWIFPrY9UNlLKG3x/Z4yY=";
  };

  dotnet-sdk = dotnetCorePackages.sdk_10_0;
  dotnet-runtime = dotnetCorePackages.runtime_10_0;

  nugetDeps = ./deps.json;

  projectFile = [
    "Examples/VisualGGPK3/VisualGGPK3.csproj"
  ];

  nativeBuildInputs = [
    wrapGAppsHook3
  ];

  runtimeDeps = [
    gtk3
    libnotify
  ];

  prePatch = ''
    substituteInPlace Directory.Build.props \
      --replace-fail 'net8.0' 'net10.0'
  '';

  postInstall = ''
    ln -sf ${liboodle-so}/*.so $out/lib/${finalAttrs.pname}
  '';

  meta = {
    description = "A cross-platfrom library for working with Content.ggpk from the game Path of Exile.";
    homepage = "https://github.com/aianlinb/LibGGPK3";
    license = lib.licenses.agpl3Only;
    mainProgram = "VisualGGPK3";
    platforms = lib.platforms.linux;
  };
})

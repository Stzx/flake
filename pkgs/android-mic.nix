{
  lib,
  rustPlatform,
  fetchgit,
  libcosmicAppHook,
  protobuf,
  libjack2,
  alsa-lib,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "android-mic";
  version = "2.2.6";

  src = fetchgit {
    url = "https://github.com/teamclouday/AndroidMic.git";
    tag = "${finalAttrs.version}";
    sparseCheckout = [
      "RustApp"
      "Assets"
    ];
    hash = "sha256-EaVaQI3oxRTolSuFrz0cqkX2edYl7HiDtzNWTtiOA3k=";
  };

  cargoRoot = "RustApp";

  cargoHash = "sha256-GechoFPC6N+oJvuDDtYj6wb3sKcam1I/T1z2VsrPCmk=";

  buildInputs = [
    libjack2

    alsa-lib
  ];

  nativeBuildInputs = [
    rustPlatform.bindgenHook

    libcosmicAppHook
    protobuf
  ];

  buildAndTestSubdir = finalAttrs.cargoRoot;

  meta = {
    description = "Use your Android phone as a microphone for your PC";
    homepage = "https://github.com/teamclouday/AndroidMic";
    license = lib.licenses.gpl3Only;
    mainProgram = "android-mic";
    platforms = lib.platforms.linux;
  };
})

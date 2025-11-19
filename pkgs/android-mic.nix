{
  lib,
  rustPlatform,
  fetchgit,
  libcosmicAppHook,
  protobuf,
  jack2,
  alsa-lib,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "android-mic";
  version = "2.2.3";

  src = fetchgit {
    url = "https://github.com/teamclouday/AndroidMic.git";
    tag = "${finalAttrs.version}";
    sparseCheckout = [
      "RustApp"
      "Assets"
    ];
    hash = "sha256-OJzilL5PeQp8hnFChtZjcQBmJQeIZ0O2WTRbgw1St4k=";
  };

  cargoRoot = "RustApp";

  cargoHash = "sha256-K0Uk5Ndxi8GSyWIKJ/BnARFal4qosdWAoGfL2ZoOGVs=";

  buildInputs = [
    jack2
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

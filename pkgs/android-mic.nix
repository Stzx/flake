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
  version = "2.2.4";

  src = fetchgit {
    url = "https://github.com/teamclouday/AndroidMic.git";
    tag = "${finalAttrs.version}";
    sparseCheckout = [
      "RustApp"
      "Assets"
    ];
    hash = "sha256-byVuodMY/eCmj/v+2kwx6i1DB0u1ktgIAtw/81Cn5IU=";
  };

  cargoRoot = "RustApp";

  cargoHash = "sha256-x6OhP72EIdTx3ptx1AIkJc6Ea70KkzPM1btYydhH7EA=";

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

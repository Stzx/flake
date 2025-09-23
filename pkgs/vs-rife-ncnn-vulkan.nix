{
  lib,
  stdenv,
  fetchgit,
  cmake,
  meson,
  ninja,
  pkg-config,
  ncnn,
  vulkan-loader,
  vapoursynth,

  # WARN: src.hash
  models ? [
    "rife-v4.4_ensembleFalse_fastTrue" # 19 = rife-v4.4 (ensemble=False / fast=True)
    "rife-v4.25-lite_ensembleFalse" # 70 = rife-v4.25-lite (ensemble=False)
  ],
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "vs-rife-ncnn-vulkan";
  version = "r9_mod_v33";

  __structuredAttrs = true;
  strictDeps = true;

  src = fetchgit {
    url = "https://github.com/styler00dollar/VapourSynth-RIFE-ncnn-Vulkan.git";
    tag = "${finalAttrs.version}";
    hash = "sha256-pEq46dy/gCQb9QJ8CRGPB7bP8a3zCaU0Cbn8GiGquXw=";
    sparseCheckout = [ "RIFE" ] ++ (builtins.map (model: "models/${model}") models);
    fetchSubmodules = false;
  };

  dontUseCmakeConfigure = true;

  mesonBuildType = "release";

  mesonFlags = [
    (lib.mesonOption "use_system_ncnn" "true")
  ];

  nativeBuildInputs = [
    cmake
    meson
    ninja
    pkg-config
  ];

  buildInputs = [
    vulkan-loader
    vapoursynth
    ncnn
  ];

  preConfigure = ''
    sed -i "s|install_dir = vapoursynth.* /|install_dir = get_option('libdir') /|" meson.build
  '';
})

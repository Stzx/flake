{
  lib,
  stdenvNoCC,
  requireFile,
  unzip,
  copyDesktopItems,
  makeDesktopItem,
  makeWrapper,
  libGL,
  temurin-jre-bin,
  rtJre ? temurin-jre-bin,
  openGLBackend ? true,
  vmOpts ? (
    lib.concatStringsSep " " (
      [
        "-Xmx1G"
        "-XX:+UseZGC"
        # "-Dsun.java2d.vulkan=true" # WAIT: wakefield release
        # "-Dawt.toolkit.name=WLToolkit" # WAIT: wakefield release
        "-Dawt.useSystemAAFontSettings=gasp"
        "-Dswing.defaultlaf=javax.swing.plaf.nimbus.NimbusLookAndFeel"
        # "-Dswing.defaultlaf=com.sun.java.swing.plaf.gtk.GTKLookAndFeel"
      ]
      ++ lib.optional openGLBackend "-Dsun.java2d.opengl=true"
    )
  ),
}:

assert lib.versionAtLeast (lib.getVersion rtJre) "17";

let
  libPath = lib.makeLibraryPath ([ ] ++ lib.optional openGLBackend libGL);
in
stdenvNoCC.mkDerivation (finalAttrs: rec {
  pname = "global-quake-bin";

  version = "1.0.1";

  src = requireFile rec {
    name = "GlobalQuake-${version}.zip";
    url = "https://files.globalquake.net/${name}";
    hash = "sha256-0U/YKudTT2xYG07Pf2CiiY/ZWUcAxKlp7kU73LjsTsQ=";
  };

  sourceRoot = "./";

  nativeBuildInputs = [
    unzip
    copyDesktopItems
    makeWrapper
  ];

  dontBuild = true;

  desktopItems = [
    (makeDesktopItem {
      name = finalAttrs.pname;
      desktopName = "Global Quake";
      exec = "global-quake";
      terminal = false;
    })
  ];

  # Um..., I really don't want to waste my energy.
  #
  # 😅
  # net.globalquake.client.main.Main:
  #
  # private static File initInstallationFolder() {
  #     String str;
  #     try {
  #         if (System.getProperty("os.name").toLowerCase().contains("win") && (str = System.getenv("LOCALAPPDATA")) != null) {
  #             return new File(str, "GlobalQuake/");
  #         }
  #     } catch (Exception e) {
  #         Logger.error("Unable to determine local app directory!", new Object[]{e});
  #     }
  #     return new File("./data/");
  # }
  #
  # private static File initMainFolder() {
  #     String str;
  #     try {
  #         if (System.getProperty("os.name").toLowerCase().contains("win") && (str = System.getenv("APPDATA")) != null) {
  #             File file = new File(str, "GlobalQuake/");
  #             System.out.printf("Windows detected, data directory will be %s%n", file.getAbsolutePath());
  #             return file;
  #         }
  #     } catch (Exception e) {
  #         Logger.error("Unable to determine data directory!", new Object[]{e});
  #     }
  #     File file2 = new File("./data/");
  #     System.out.printf("Defaulting data directory to %s%n", file2.getAbsolutePath());
  #     return file2;
  # }
  #
  # Niri need: _JAVA_AWT_WM_NONREPARENTING
  installPhase = ''
    runHook preInstall

    install -Dm644 -t $out/share/${pname}/ ./bin/GlobalQuake.jar
    install -Dm644 -t $out/share/${pname}/libs/ ./libs/*.jar

    # --run "mkdir -p \$XDG_RUNTIME_DIR/global-quake/ && cd \$XDG_RUNTIME_DIR/global-quake/" \
    makeWrapper ${lib.getExe rtJre} $out/bin/${meta.mainProgram} \
      --set _JAVA_AWT_WM_NONREPARENTING 1 \
      --prefix LD_LIBRARY_PATH : "${libPath}" \
      --run "mkdir -p \$XDG_CACHE_HOME/global-quake/ && cd \$XDG_CACHE_HOME/global-quake/" \
      --add-flags "${vmOpts} -cp $out/share/${pname}/GlobalQuake.jar:$out/share/${pname}/libs/* net.globalquake.client.main.Main"

    runHook postInstall
  '';

  passthru = {
    inherit vmOpts;
  };

  meta = {
    homepage = "https://globalquake.net/";
    description = "The world's first free full live global earthquake detection system.";
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    mainProgram = "global-quake";
    license = lib.licenses.unfree;
    platforms = lib.platforms.linux;
    maintainers = [ ];
  };
})

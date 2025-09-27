{
  lib,
  stdenvNoCC,
  fetchgit,
  nodejs,
  pnpm,
  maven,
  makeWrapper,
  temurin-jre-bin,
  pbhJre ? temurin-jre-bin,
  vmOpts ? "-XX:+UseZGC -XX:+ZGenerational",
}:

assert lib.versionAtLeast (lib.getVersion pbhJre) "21";

let
  pname = "peer-ban-helper";

  version = "8.0.12";

  src = fetchgit {
    url = "https://github.com/PBH-BTN/PeerBanHelper.git";
    tag = "v${version}";
    hash = "sha256-iRf4eH8zGI+ixJAjMLB4FR7sz+hTsfECit+pFvgol3k=";
    leaveDotGit = true; # git-commit-id-maven-plugin
  };

  webui = stdenvNoCC.mkDerivation (finalAttrs: {
    inherit version src;

    pname = "${pname}-webui";

    sourceRoot = "${finalAttrs.src.name}/webui";

    nativeBuildInputs = [
      nodejs
      pnpm.configHook
    ];

    # pnpmRoot = "webui";

    pnpmDeps = pnpm.fetchDeps {
      inherit (finalAttrs)
        pname
        version
        src
        sourceRoot
        ;

      fetcherVersion = 2;
      hash = "sha256-WYgyBEEsn3WjIaG0eJE2ymqOsXKULrHkNtImYVMGXLk=";
    };

    buildPhase = ''
      runHook preBuild

      pnpm run build

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      cp -r ./dist/ $out/

      runHook postInstall
    '';
  });
in
maven.buildMavenPackage rec {
  inherit pname version src;

  outputs = [
    "out"
    "doc"
  ];

  nativeBuildInputs = [ makeWrapper ];

  # 有些可疑的 repository URLs
  # 我虽然打包了，但并没有使用该软件
  mvnHash = "sha256-a4ODvFRIuiHA7BbyIk67OjMlrMQHCdDXsOvVntN6EMM=";

  preBuild = ''
    cp -r ${webui}/ src/main/resources/static/
  '';

  # PACKAGING.md
  #
  # pbh.datadir, pbh.configdir, pbh.logsdir
  #
  # swing, swt, qt, nogui, silent
  installPhase = ''
    runHook preInstall

    install -Dm644 -t $out/share/${pname}/ ./target/*.jar
    install -Dm644 -t $out/share/${pname}/libraries/ ./target/libraries/*

    install -Dm444 -t $doc/share/doc/${pname}/ ./pkg/deb/usr/share/doc/peerbanhelper/*

    makeWrapper ${lib.getExe pbhJre} $out/bin/${meta.mainProgram} \
      --add-flags "${vmOpts} -Dpbh.release=nixos -jar $out/share/${pname}/PeerBanHelper.jar"

    runHook postInstall
  '';

  meta = {
    description = "自动封禁不受欢迎、吸血和异常的 BT 客户端";
    homepage = "https://github.com/PBH-BTN/PeerBanHelper";
    license = lib.licenses.gpl3Only;
    mainProgram = "peer-ban-helper";
    platforms = lib.platforms.all;
  };
}

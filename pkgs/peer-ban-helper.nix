{
  lib,
  stdenvNoCC,
  fetchgit,
  nodejs,
  pnpm,
  maven,
  makeWrapper,
  temurin-jre-bin,
  rtJre ? temurin-jre-bin
}:

let
  pname = "peer-ban-helper";

  version = "8.0.11";

  src = fetchgit {
    url = "https://github.com/PBH-BTN/PeerBanHelper.git";
    tag = "v${version}";
    hash = "sha256-/Z8u7qHS8cVh3gBWJnWXkaqAVOTj2XNl0klgJvFgOLM=";
    leaveDotGit = true; # git-commit-id-maven-plugin
  };

  webui = stdenvNoCC.mkDerivation (finalAttrs: {
    inherit version src;

    pname = "${pname}-webui";

    sourceRoot = "${finalAttrs.src.name}/webui";

    # env.NIX_NPM_REGISTRY = "https://r.cnpmjs.org/";

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

  nativeBuildInputs = [    makeWrapper  ];

  # 有些可疑的 repository URLs
  # 我虽然打包了，但并没有使用该软件
  mvnHash = "sha256-a4ODvFRIuiHA7BbyIk67OjMlrMQHCdDXsOvVntN6EMM=";

  preBuild = ''
    cp -r ${webui}/ src/main/resources/static/
  '';

  installPhase = ''
    runHook preInstall

    install -Dm644 -t $out/share/${pname}/ ./target/*.jar
    install -Dm644 -t $out/share/${pname}/libraries ./target/libraries/*

    makeWrapper ${lib.getExe rtJre} $out/bin/${meta.mainProgram} \
      --add-flags "-jar $out/share/${pname}/PeerBanHelper.jar"

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

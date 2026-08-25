{
  lib,
  stdenvNoCC,
  fetchurl,
  _7zz,
  installFonts,
}:

let

  hashes = lib.importJSON ./hashes.json;

  repoUrl = "https://github.com/takushun-wu/WenYuanFonts";

  wen-yuan-font =
    {
      pname,
      fname,
      desc,
    }:
    let
      archive = lib.hasSuffix ".7z" fname;
    in
    stdenvNoCC.mkDerivation (finalAttrs: {
      inherit pname;

      version = "1.010";

      src = fetchurl {
        url = "${repoUrl}/releases/download/v${finalAttrs.version}/${fname}";
        hash = hashes.${fname};
      };

      sourceRoot = ".";

      nativeBuildInputs = [ installFonts ] ++ lib.optional archive _7zz;

      unpackPhase = ''
        runHook preUnpack

        ${if archive then "7zz x $src" else "cp -v $src ./${fname}"}

        runHook postUnpack
      '';

      meta = {
        homepage = repoUrl;
        description = "WenYuan ${desc}";
        license = lib.licenses.ofl;
        platforms = lib.platforms.all;
        maintainers = [ ];
      };
    });

  families = {
    rounded = {
      name = "Rounded";
    };
    serif = {
      name = "Serif";
    };
    sans = {
      name = "Sans";
    };
  };

  formats = {
    otf = {
      suffix = "SC-OTF.7z";
      desc = "OpenType";
    };
    # ttf = {
    #   suffix = "SC-TTF.7z";
    #   desc = "TrueType";
    # };
    vf-otf = {
      suffix = "SCVF.otf";
      desc = "variable OpenType";
    };
    # vf-ttf = {
    #   suffix = "SCVF.ttf";
    #   desc = "variable TrueType";
    # };
  };
in

lib.concatMapAttrs (
  famName: fam:
  lib.concatMapAttrs (
    fmtName: fmt:
    let
      pname = lib.removeSuffix ".7z" (lib.removeSuffix ".otf" (lib.removeSuffix ".ttf" fname));
      fname = "WenYuan${fam.name}${fmt.suffix}";
    in
    {
      "${famName}-${fmtName}" = wen-yuan-font {
        inherit pname fname;
        desc = "${fam.name} ${fmt.desc}";
      };
    }
  ) formats
) families

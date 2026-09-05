{
  lib,
  stdenvNoCC,
  unzip,
  fetchurl,
  installFonts,
}:

let

  hashes = lib.importJSON ./hashes.json;

  maple-font =
    {
      pname,
      hash,
      desc,
    }:
    stdenvNoCC.mkDerivation rec {
      inherit pname;
      version = "1788611750"; # 8.0-beta.2
      src = fetchurl {
        url = "https://github.com/Stzx/Maple-font/releases/download/v${version}/${pname}.zip";
        inherit hash;
      };

      # Work around the "unpacker appears to have produced no directories"
      # case that happens when the archive doesn't have a subdirectory.
      sourceRoot = ".";
      nativeBuildInputs = [
        unzip
        installFonts
      ];

      meta = {
        homepage = "https://github.com/subframe7536/Maple-font";
        description = ''
          Open source ${desc} font with round corner and ligatures for IDE and command line
        '';
        license = lib.licenses.ofl;
        platforms = lib.platforms.all;
      };
    };

  cjkVariants = {
    CN = {
      suffix = "CN";
      desc = "Simplified Chinese, with common Traditional Chinese and Japanese ranges";
    };
    TC = {
      suffix = "TC";
      desc = "Traditional Chinese";
    };
    JP = {
      suffix = "JP";
      desc = "Japanese";
    };
    KR = {
      suffix = "KR";
      desc = "Korean";
    };
  };

  cjkTypeVariants = {
    unhinted = {
      suffix = "-unhinted";
      desc = "unhinted";
    };
  };

  toVariantList = variants: lib.mapAttrsToList (_: v: { inherit (v) suffix desc; }) variants;

  cjkSuffix = combo: with combo; "-${lang.suffix}${type.suffix}";
  cjkDesc = combo: with combo; "${lang.desc} ${type.desc}";
  cjkCombos = lib.cartesianProduct {
    lang = toVariantList cjkVariants;
    type = toVariantList cjkTypeVariants;
  };

  mkPkgs =
    combos: getSuffix: getDesc:
    builtins.listToAttrs (
      map (
        combo:
        let
          suffix = getSuffix combo;

          pname = "MapleMono${suffix}";
        in
        lib.nameValuePair "${lib.removePrefix "-" suffix}" (maple-font {
          inherit pname;
          desc = getDesc combo;
          hash = hashes.${pname};
        })
      ) combos
    );

  combinedFonts = (mkPkgs cjkCombos cjkSuffix cjkDesc);

in
combinedFonts

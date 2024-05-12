{ lib
, config
}:

rec {
  isKDE = config.features.desktop.kde;

  haveAnyDE = isKDE;

  attrNeedDE = attr: if haveAnyDE then attr else { };

  listNeedDE = list: if haveAnyDE then list else [ ];

  mkIfAnyDE = attr: lib.mkIf haveAnyDE attr;

  desktopAssert = {
    assertion = haveAnyDE;
    message = "Desktop environment is not enabled";
  };
}

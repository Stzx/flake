{
  lib,
  config,
}:

let
  wm = config.features.wm;
in
rec {
  isKDE = wm.kde;

  isHyprland = wm.hyprland;

  haveAnyWM = isKDE || isHyprland;

  attrNeedWM = attr: if haveAnyWM then attr else { };

  listNeedWM = list: if haveAnyWM then list else [ ];

  desktopAssert = {
    assertion = haveAnyWM;
    message = "Desktop environment is not enabled";
  };
}

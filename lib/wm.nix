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

  isNiri = wm.niri;

  haveAnyWM = isKDE || isHyprland || isNiri;

  attrNeedWM = attr: if haveAnyWM then attr else { };

  listNeedWM = list: if haveAnyWM then list else [ ];
}

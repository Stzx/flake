{ lib, ... }:

cfg:

with cfg.features.wm; rec {
  inherit enable;

  isEnable = enable != null;
  isKDE = enable == "kde";
  isNiri = enable == "niri";
  isHyprland = enable == "hyprland";

  getExe =
    if isKDE then
      "startplasma-wayland"
    else if isHyprland then
      "Hyprland"
    else if isNiri then
      "niri-session"
    else
      null;
}

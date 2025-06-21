{ lib, ... }:

cfg:

with cfg.features.wm; rec {
  inherit enable;

  isEnable = enable != null;
  isKDE = enable == "kde";
  isNiri = enable == "niri";

  getExe =
    if isKDE then
      "startplasma-wayland"
    else if isNiri then
      "niri-session"
    else
      null;
}

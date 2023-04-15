{ config, lib, pkgs }:

let
  utils = import "${pkgs}/nixos/lib/utils.nix" { inherit config lib pkgs; };

  kernel = import ./kernel.nix { inherit lib; };

  fs = import ./fs.nix { inherit lib utils; };

  desktop = import ./desktop.nix { inherit config lib; };
in
{
  inherit (kernel) mkPatch mkPatchs;

  inherit (fs) byUUID nvmeEui fstab timeOptions btrfsOptions f2fsOptions btrfsMountUnit f2fsMountUnit;

  inherit (desktop) haveAnyDE isKDE mkDesktopCfg;
}

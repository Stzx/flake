{ lib }:

dir:
let
  findFiles =
    dir:
    lib.flatten (
      lib.mapAttrsToList (
        name: type:
        if type == "directory" then
          findFiles (dir + "/${name}")
        else if type == "regular" && lib.strings.hasSuffix ".m.nix" name then
          [ (dir + "/${name}") ]
        else
          [ ]
      ) (builtins.readDir dir)
    );

  modules = map (f: import f) (findFiles dir);

  mergedAttrs = lib.foldl (
    acc: module: acc // (lib.mapAttrs (name: value: (acc.${name} or [ ]) ++ [ value ]) module)
  ) { } modules;
in
mergedAttrs

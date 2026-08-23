{
  mkPkgs,
  mkSystem,
  mkHomeManager,
  lib,
  ...
}:

let
  kernel = import ./kernel.nix { inherit lib; };

  fs = import ./fs.nix { inherit lib; };

  modules = import ./modules.nix { inherit lib; };
in
{
  inherit mkPkgs mkSystem mkHomeManager;

  inherit (kernel) mkPatch mkPatchs;

  inherit (fs)
    byUuid
    byId
    byLabel
    byNVMeEui

    timeOptions
    dataOptions
    btrfsOptions
    xfsOptions
    f2fsOptions
    exfaOptions

    mergeMounts'

    btrfsMounts
    xfsMounts
    f2fsMounts
    exfatMounts
    ;

  scanModules = modules;

  mergeEnv =
    flags: prev:
    let
      env' = prev.env or { };

      merge =
        env: name:
        let
          val' = env.${name} or null;
          flags' = if val' != null then [ val' ] else [ ];
          combined = flags' ++ flags.${name};
        in
        env // { ${name} = toString combined; };

      env = builtins.foldl' merge env' (builtins.attrNames flags);
    in
    {
      inherit env;
    };
}

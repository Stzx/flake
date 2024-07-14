{ lib }:

let
  args = with lib.kernel; {
    default = lib.mkDefault;
    force = lib.mkForce;
    y = yes;
    n = no;
    u = unset;
    m = module;
    ff = freeform;
  };

  pair = name: value: lib.nameValuePair (lib.removePrefix "CONFIG_" name) (lib.mkForce value);
in
rec {
  # Format: { ENABLE } //  { DISABLE } // { NixOS DISABLE WARN/ERROR }
  # FIXME: 不同的 DISABLE 可能冲突
  mkPatchAttrs = { origin ? ./., suffix ? "", name }:
    let
      f = origin + "/kernel/${name}${suffix}.nix";
    in
    lib.optionalAttrs (builtins.pathExists f) (lib.mapAttrs' pair (import f args));

  mkPatch = { origin, name, suffixes ? [ ] }:
    let
      commonAttrs = mkPatchAttrs { inherit name; };

      hostAttrs = mkPatchAttrs { inherit origin name; };

      suffixAttrs = (lib.foldl (f: p: f // mkPatchAttrs { inherit origin name; suffix = "-${p}"; }) { } suffixes);
    in
    {
      inherit name;
      patch = null;
      extraStructuredConfig = (commonAttrs // hostAttrs // suffixAttrs);
    };

  mkPatchs = args: lib.forEach args (e: mkPatch e);
}

final: prev: {
  firefox = prev.firefox.override { cfg.speechSynthesisSupport = false; };

  jetbrains =
    let
      vmopts = ''
        -Xms3072m
        -Xmx6144m
        -XX:ReservedCodeCacheSize=1024m
        -XX:MaxMetaspaceSize=1024m
      '';
    in
    prev.jetbrains
    // {
      idea-community = prev.jetbrains.idea-community.override { inherit vmopts; };
      rust-rover = prev.jetbrains.rust-rover.override { inherit vmopts; };
    };
}

final: prev: {
  nerdfonts = prev.nerdfonts.override {
    fonts = [
      "IosevkaTerm"
      "IosevkaTermSlab"
    ];
  };

  jetbrains = prev.jetbrains // {
    idea-community = prev.jetbrains.idea-community.override {
      vmopts = ''
        -Xms3072m
        -Xmx6144m
        -XX:ReservedCodeCacheSize=1024m
        -XX:MaxMetaspaceSize=1024m
      '';
    };
  };
}

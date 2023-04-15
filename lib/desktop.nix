{ config, lib }:

rec {
  haveAnyDE = isKDE;

  isKDE = config.features.desktop.kde;

  mkDesktopAssert = {
    assertions = [
      {
        assertion = haveAnyDE;
        message = "Dstkop environment is not enabled";
      }
    ];
  };

  mkDesktopMerge = configs: lib.mkMerge ([ (mkDesktopAssert) ] ++ configs);

  mkDesktopCfg = cond: configs: lib.mkIf cond (mkDesktopMerge configs);
}

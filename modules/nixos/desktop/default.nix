{ lib, pkgs, my, ... }:

{
  imports = [ ./kde ];

  config = lib.mkIf my.haveAnyDE {
    fonts = {
      packages = lib.mkForce (with pkgs; [
        source-han-sans
        source-han-serif
        source-han-mono

        nerdfonts

        material-icons
      ]);
      fontconfig = {
        enable = true;
        subpixel.rgba = "rgb";
        defaultFonts = lib.mkForce {
          serif = [
            "Source Han Serif SC"
            "Source Han Serif HC"
            "Source Han Serif TC"
            "Source Han Serif K"
            "Source Han Serif"
          ];
          sansSerif = [
            "Source Han Sans SC"
            "Source Han Sans HC"
            "Source Han Sans TC"
            "Source Han Sans K"
            "Source Han Sans"
          ];
          monospace = [
            "Source Han Mono SC"
            "Source Han Mono HC"
            "Source Han Mono TC"
            "Source Han Mono K"
            "Source Han Mono"
          ];
          emoji = [ "Material Icons" ];
        };
      };
    };
  };
}

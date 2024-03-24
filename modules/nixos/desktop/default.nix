{ lib, pkgs, my, ... }:

{
  imports = [ ./kde ];

  config = lib.mkIf my.haveAnyDE {
    fonts = {
      packages = with pkgs; [
        source-han-sans
        source-han-serif
        source-han-mono

        nerdfonts

        material-icons
      ];
      fontconfig = {
        enable = true;
        subpixel.rgba = "rgb";
        defaultFonts = lib.mkForce {
          serif = [
            "Source Han Serif"
            "Source Han Serif SC"
            "Source Han Serif TC"
            "Source Han Serif HC"
            "Source Han Serif K"
          ];
          sansSerif = [
            "Source Han Sans"
            "Source Han Sans SC"
            "Source Han Sans TC"
            "Source Han Sans HC"
            "Source Han Sans K"
          ];
          monospace = [
            "Source Han Mono"
            "Source Han Mono SC"
            "Source Han Mono TC"
            "Source Han Mono HC"
            "Source Han Mono K"
          ];
          emoji = [ "Material Icons" ];
        };
      };
    };
  };
}

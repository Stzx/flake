{ pkgs
, lib
, ...
}:

{
  imports = [ ./kde.nix ];

  config = lib.mkMerge [{
    fonts = {
      packages = with pkgs; [
        source-han-serif
        # source-han-sans
        # source-han-mono

        sarasa-gothic

        nerdfonts

        noto-fonts-color-emoji
      ];
      fontconfig = {
        enable = true;
        subpixel.rgba = "rgb";
        defaultFonts = lib.mkForce {
          serif = [
            "Source Han Serif SC"
            "Source Han Serif TC"
            "Source Han Serif HC"
            "Source Han Serif K"
            "Source Han Serif"
          ];
          sansSerif = [
            "Sarasa UI SC"
            "Sarasa UI TC"
            "Sarasa UI HC"
            "Sarasa UI J"
            "Sarasa UI K"
          ];
          monospace = [
            "Sarasa Mono SC"
            "Sarasa Mono TC"
            "Sarasa Mono HC"
            "Sarasa Mono J"
            "Sarasa Mono K"
          ];
          emoji = [
            "Noto Color Emoji"
          ];
        };
      };
    };
  }];
}

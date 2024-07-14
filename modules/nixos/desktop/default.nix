{ pkgs
, lib
, ...
}:

{
  imports = [ ./kde.nix ];

  config = lib.mkMerge [{
    fonts = {
      packages = with pkgs; [
        # source-han-serif
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
            "Sarasa Term Slab SC"
            "Sarasa Term Slab TC"
            "Sarasa Term Slab HC"
            "Sarasa Term Slab J"
            "Sarasa Term Slab K"
          ];
          sansSerif = [
            "Sarasa Term SC"
            "Sarasa Term TC"
            "Sarasa Term HC"
            "Sarasa Term J"
            "Sarasa Term K"
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

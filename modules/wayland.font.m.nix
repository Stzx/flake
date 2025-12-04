{
  sys =
    { pkgs, lib, ... }:

    let
      inherit (lib) mkDefault;

      concatStrings = lib.concatMapStringsSep "\n";

      fontMatch =
        lang: family: fonts:

        if (fonts != [ ]) then
          ''
            <match>
            <test name="lang"><string>${lang}</string></test>
            <test name="family"><string>${family}</string></test>
              <edit name="family" mode="prepend" binding="same">
            ${concatStrings (f: "<string>${f}</string>") fonts}
              </edit>
            </match>
          ''
        else
          "";

      matchesByLang =
        lang: sansSerif: serif: mono:

        lib.concatStrings [
          (fontMatch lang "sans-serif" sansSerif)
          (fontMatch lang "serif" serif)
          (fontMatch lang "monospace" mono)
        ];
    in
    {
      fonts = {
        enableDefaultPackages = false;
        packages = with pkgs; [
          # source-han-serif
          # source-han-sans
          # source-han-mono

          monaspace.variable
          # comic-mono
          # victor-mono
          maple-mono.CN-unhinted

          # lxgw-wenkai
          # lxgw-wenkai-tc

          # Gothic, UI = Inter
          #   Quotes (“”) are full width —— Gothic
          #   Quotes (“”) are narrow —— UI
          #
          # Mono, Term, Fixed = Iosevka
          #   | suffix | half width | ligature |
          #   |--------|:----------:|:--------:|
          #   | Mono   |      N     |     Y    |
          #   | Term   |      Y     |     Y    |
          #   | Fixed  |      Y     |     N    |
          #
          #   Em dashes (——) are full width —— Mono
          #   Em dashes (——) are half width —— Term
          #   No ligature, Em dashes (——) are half width —— Fixed
          #
          # Orthography dimension
          #   CL: Classical orthography
          #   SC, TC, J, K, HC: Regional orthography, following Source Han Sans notations.
          sarasa-gothic

          # noto-fonts-cjk-serif
          # noto-fonts-cjk-sans
          noto-fonts-color-emoji

          nerd-fonts.symbols-only
        ];
        fontconfig = {
          enable = true;
          includeUserConf = mkDefault false;
          hinting.enable = mkDefault false;
          defaultFonts = lib.mkForce {
            sansSerif = [ "Sarasa Gothic SC" ];
            serif = [ "Sarasa Fixed Slab SC" ];
            monospace = [ "Sarasa Mono SC" ];
            emoji = [ "Noto Color Emoji" ];
          };
          localConf = ''
            <?xml version="1.0" encoding="UTF-8"?>
            <!DOCTYPE fontconfig SYSTEM "urn:fontconfig:fonts.dtd">
            <fontconfig>
            ${matchesByLang "zh-hk" [ "Sarasa Gothic HC" ] [ "Sarasa Fixed Slab HC" ] [ "Sarasa Mono HC" ]}
            ${matchesByLang "zh-tw" [ "Sarasa Gothic TC" ] [ "Sarasa Fixed Slab TC" ] [ "Sarasa Mono TC" ]}

            ${matchesByLang "ja" [ "Sarasa Gothic J" ] [ "Sarasa Fixed Slab J" ] [ "Sarasa Mono J" ]}
            ${matchesByLang "ko" [ "Sarasa Gothic K" ] [ "Sarasa Fixed Slab K" ] [ "Sarasa Mono K" ]}
            </fontconfig>
          '';
        };
      };
    };
}

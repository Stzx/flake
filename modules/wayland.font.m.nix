{
  sys =
    { pkgs, lib, ... }:

    let
      inherit (lib) mkDefault;

      fontMatch =
        lang: family: fonts:

        lib.optionalString (fonts != [ ]) ''
          <match>
            <test name="lang"><string>${lang}</string></test>
            <test name="family"><string>${family}</string></test>
            <edit name="family" mode="prepend" binding="same">
              ${lib.concatMapStrings (f: "<string>${f}</string>") fonts}
            </edit>
          </match>
        '';

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

          # monaspace.variable
          # comic-mono
          # # victor-mono
          # iosevka

          custom-release-maple-mono.CN-unhinted
          custom-release-maple-mono.TC-unhinted
          custom-release-maple-mono.JP-unhinted
          custom-release-maple-mono.KR-unhinted

          wen-yuan-fonts.rounded-otf
          wen-yuan-fonts.serif-otf

          # lxgw-wenkai
          # lxgw-wenkai-tc
          lxgw-wenkai-screen

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
          # sarasa-gothic-unhinted

          sparse-noto-fonts
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
            sansSerif = [ "WenYuan Rounded SC" ];
            serif = [ "WenYuan Serif SC" ];
            monospace = [ "Maple Mono CN" ];
            emoji = [ "Noto Color Emoji" ];
          };
          localConf = ''
            <?xml version="1.0" encoding="UTF-8"?>
            <!DOCTYPE fontconfig SYSTEM "urn:fontconfig:fonts.dtd">
            <fontconfig>
            ${matchesByLang "zh-hk" [ ] [ ] [ "Maple Mono TC" ]}
            ${matchesByLang "zh-tw" [ ] [ ] [ "Maple Mono TC" ]}

            ${matchesByLang "ja" [ ] [ ] [ "Maple Mono JP" ]}
            ${matchesByLang "ko" [ ] [ ] [ "Maple Mono KR" ]}
            </fontconfig>
          '';
        };
      };
    };
}

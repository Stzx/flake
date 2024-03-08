final: prev: {
  nerdfonts = prev.nerdfonts.override {
    fonts = [
      "Iosevka"
      "JetBrainsMono"
      "LiberationMono"
      "Ubuntu"
      "UbuntuMono"
    ];
  };

  netdata = prev.netdata.override {
    withIpmi = false;
    withSsl = false;
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

  vimPlugins = prev.vimPlugins // {
    hlchunk-nvim = final.vimUtils.buildVimPlugin {
      pname = "hlchunk-nvim";
      version = "2023-12-11";
      src = final.fetchFromGitHub {
        owner = "shellRaining";
        repo = "hlchunk.nvim";
        rev = "882d1bc86d459fa8884398223c841fd09ea61b6b";
        sha256 = "fvFvV7KAOo7xtOCjhGS5bDUzwd10DndAKs3++dunED8=";
      };
      meta = {
        description = "This is the lua implementation of nvim-hlchunk, you can use this neovim plugin to highlight your indent line and the current chunk (context) your cursor stayed";
        homepage = "https://github.com/shellRaining/hlchunk.nvim";
      };
    };
  };
}

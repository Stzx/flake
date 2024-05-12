{ pkgs
, ...
}:

{
  programs.git.extraConfig = {
    init = {
      defaultBranch = "main";
    };
    fetch = {
      prune = true;
      pruneTags = true;
    };
    pull = {
      rebase = true;
    };
    push = {
      autoSetupRemote = true;
    };
    protocol = {
      file.allow = "always";
    };
  };

  programs.direnv = {
    enable = true;
    enableBashIntegration = true;
    nix-direnv.enable = true;
    config.global.warn_timeout = "30s";
  };

  home.file = {
    ".cargo/config.toml".text = ''
      [source.crates-io]
      replace-with = 'ustc'

      [source.ustc]
      registry = "sparse+https://mirrors.ustc.edu.cn/crates.io-index/"

      [build]
      rustc-wrapper = "${pkgs.sccache}/bin/sccache"
    '';
  };
}

{
  sys =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    {
      environment.systemPackages = with pkgs; [
        lsb-release

        lsof
        file

        tree
        _7zz
      ];

      networking.firewall.extraPackages = with pkgs; [
        dnsutils
        radvd
      ];

      programs.htop = {
        enable = true;
        settings = {
          hide_userland_threads = true;
          show_thread_names = true;
          show_merged_command = true;
          shadow_other_users = true;
          highlight_base_name = true;
          highlight_threads = true;
          highlight_changes = true;
          tree_view = true;
          tree_view_always_by_pid = true;
        };
      };
    };

  home =
    {
      pkgs,
      lib,
      config,
      ...
    }:

    let
      cfg = config.programs;
    in
    {
      config = lib.mkMerge [
        {
          xdg.enable = true;

          programs = {
            home-manager.enable = true;

            zsh.enable = true;

            git.enable = true;

            neovim.enable = true;
          };

          programs.delta = {
            enable = true;
            enableGitIntegration = config.programs.git.enable;
            options = {
              line-numbers = true;
              side-by-side = true;
            };
          };
        }

        (lib.mkIf cfg.direnv.enable {
          programs.direnv = {
            nix-direnv.enable = true;
            config.global.warn_timeout = "30s";
          };

          programs.git.settings = {
            init.defaultBranch = "main";
            fetch = {
              prune = true;
              pruneTags = true;
            };
            pull.rebase = true;
            push.autoSetupRemote = true;
            protocol.file.allow = "always";
          };

          home.file.".cargo/config.toml".text = ''
            [source.crates-io]
            replace-with = 'ustc'

            [source.ustc]
            registry = "sparse+https://mirrors.ustc.edu.cn/crates.io-index/"

            [registries.ustc]
            index = "sparse+https://mirrors.ustc.edu.cn/crates.io-index/"

            [build]
            rustc-wrapper = "${pkgs.sccache}/bin/sccache"
          '';
        })
      ];
    };
}

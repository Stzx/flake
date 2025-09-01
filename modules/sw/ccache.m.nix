{
  sys =
    {
      pkgs,
      lib,
      config,
      ...
    }:

    # ;( https://github.com/NixOS/nixpkgs/blob/nixos-unstable/nixos/modules/programs/ccache.nix
    let
      inherit (lib) types mkOption;

      cfg = config.features.ccache;
    in
    {
      options.features.ccache = {
        enable = mkOption {
          type = types.bool;
          default = false;
        };
        cacheDir = mkOption {
          type = types.path;
          default = "/var/cache/ccache";
        };
        owner = mkOption {
          type = types.str;
          default = "root";
        };
        group = mkOption {
          type = types.str;
          default = "nixbld";
        };
        exports = mkOption {
          type = types.str;
          default = ''
            export CCACHE_DIR="${cfg.cacheDir}"
            export CCACHE_MAXSIZE=8Gi
            export CCACHE_COMPRESS=1
            export CCACHE_UMASK=007
            export CCACHE_SLOPPINESS=random_seed
          '';
        };
      };

      config = lib.mkIf cfg.enable {
        nix.settings.extra-sandbox-paths = [ cfg.cacheDir ];

        systemd.tmpfiles.rules = [ "d ${cfg.cacheDir} 0770 ${cfg.owner} ${cfg.group} -" ];

        security.wrappers.nix-ccache = {
          inherit (cfg) owner group;
          setuid = false;
          setgid = true;
          source = pkgs.writeShellScript "nix-ccache" ''
            ${cfg.exports}
            exec ${lib.getExe pkgs.ccache} "$@"
          '';
        };

        nixpkgs.overlays = [
          (final': prev': {
            ccacheWrapper = prev'.ccacheWrapper.override {
              extraConfig = ''
                ${cfg.exports}
                if [ ! -d "$CCACHE_DIR" ]; then
                  echo "====="
                  echo "Directory '$CCACHE_DIR' does not exist"
                  echo "Please create it with:"
                  echo "  sudo mkdir -m0770 '$CCACHE_DIR'"
                  echo "  sudo chown root:nixbld '$CCACHE_DIR'"
                  echo "====="
                  exit 1
                fi
                if [ ! -w "$CCACHE_DIR" ]; then
                  echo "====="
                  echo "Directory '$CCACHE_DIR' is not accessible for user $(whoami)"
                  echo "Please verify its access permissions"
                  echo "====="
                  exit 1
                fi
              '';
            };
          })
        ];
      };
    };
}

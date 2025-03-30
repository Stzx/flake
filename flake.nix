{
  description = "NixOS";

  inputs = {
    systems = {
      url = "path:./flake.systems.nix";
      flake = false;
    };

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.2";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.systems.follows = "systems";
    };

    flake-secrets = {
      url = "git+file:./../flake-secrets";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      flake-utils,
      flake-secrets,
      disko,
      lanzaboote,
      niri,
      ...
    }@inputs:
    let
      stateVersion = "24.05";

      mkPkgs =
        system:
        import nixpkgs {
          localSystem = {
            inherit system;
          };
          config = {
            allowAliases = false;
            allowUnfree = true;
          };
          overlays = [
            niri.overlays.niri
            flake-secrets.overlays.default

            self.overlays.default
          ];
        };

      mkLib = hostName: rec {
        os = self.nixosConfigurations.${hostName};

        osConfig = os.config;

        lib = nixpkgs.lib.extend (
          final: _: rec {
            my = import ./lib {
              config = osConfig;
              lib = final;
            };
            hm = home-manager.lib.hm;

            inherit (my)
              isKDE
              isSway
              isHyprland
              isNiri
              ;
          }
        );
      };

      mkHomeManager =
        username: hostName:
        let
          inherit (mkLib hostName) os osConfig lib;

          mark = "${username}@${hostName}";

          userModule = ./. + "/home-manager/${mark}";

          hmSecrets = flake-secrets.lib.hmModule username hostName;
        in
        {
          "${mark}" = home-manager.lib.homeManagerConfiguration {
            inherit (os) pkgs;
            inherit lib;

            extraSpecialArgs = {
              inherit (hmSecrets) secrets;
              inherit osConfig;

              dots = ./dots;
            };
            modules =
              [
                ./home-manager
                ./modules/home-manager

                {
                  imports = [ niri.homeModules.config ];

                  home = {
                    inherit stateVersion username;

                    homeDirectory = "/home/${username}";
                  };
                }
              ]
              ++ lib.optional (builtins.pathExists userModule) userModule
              ++ lib.optional (hmSecrets ? module) hmSecrets.module;
          };
        };

      mkSystem =
        hostName:
        {
          system ? "x86_64-linux",
        }:
        let
          inherit (mkLib hostName) lib;

          osSecrets = flake-secrets.lib.nixosModule hostName;
        in
        {
          "${hostName}" = lib.nixosSystem {
            inherit lib;

            specialArgs = {
              inherit (osSecrets) secrets;
            };
            modules = [
              disko.nixosModules.disko
              lanzaboote.nixosModules.lanzaboote
              niri.nixosModules.niri

              ./nixos
              ./modules/nixos
              (./. + "/nixos/${hostName}")

              {
                nixpkgs.pkgs = (mkPkgs system);

                system = {
                  inherit stateVersion;
                };

                networking = {
                  inherit hostName;
                };
              }
            ] ++ lib.optional (osSecrets ? module) osSecrets.module;
          };
        };
    in
    {
      overlays.default = import ./flake.overlays.nix;

      nixosConfigurations =
        (flake-secrets.nixosConfigurations { inherit mkPkgs mkLib mkSystem; })
        // (mkSystem "nos" { })
        // (mkSystem "vnos" { });

      homeConfigurations =
        (flake-secrets.homeConfigurations { inherit mkPkgs mkLib mkHomeManager; })
        // (mkHomeManager "stzx" "nos")
        // (mkHomeManager "drop" "vnos");
    }
    // flake-utils.lib.eachDefaultSystem (system: {
      devShells = import ./flake.shells.nix { pkgs = (mkPkgs system); };

      formatter = nixpkgs.legacyPackages.${system}.nixfmt-rfc-style;
    });
}

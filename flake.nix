{
  description = "NixOS";

  inputs = {
    systems.url = "github:nix-systems/default-linux";

    nixpkgs.url = "git+https://github.com/NixOS/nixpkgs.git?ref=nixos-unstable&shallow=1";

    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.2";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "git+https://github.com/nix-community/home-manager.git?ref=master&shallow=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.systems.follows = "systems";
    };

    flake-secrets.url = "git+file:./../flake-secrets";

    niri = {
      url = "github:sodiboo/niri-flake";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        nixpkgs-stable.follows = "nixpkgs";
      };
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      flake-utils,
      flake-secrets,
      niri,
      ...
    }@args:
    let
      stateVersion = "25.05";

      modules' = self.lib.scanModules ./modules;

      mkPkgs =
        system:
        import nixpkgs {
          localSystem = { inherit system; };
          config = {
            allowAliases = false;
            allowUnfree = true;
          };
          overlays = [
            self.overlays.default
            flake-secrets.overlays.default
          ];
        };

      mkSystem =
        hostName:
        {
          system ? "x86_64-linux",
          secrets ? (flake-secrets.lib.nixosModule hostName),
          modules ? [
            args.lanzaboote.nixosModules.lanzaboote

            (./. + "/nixos/${hostName}")

            secrets.module
          ],
        }:
        let
          pkgs = (mkPkgs system);
        in
        {
          "${hostName}" = nixpkgs.lib.nixosSystem {
            specialArgs = {
              inherit self;
              inherit (secrets) values;

              wmCfg = (self.lib.wm' self.nixosConfigurations."${hostName}".config);
              dots = ./dots;
            };
            modules = [
              args.disko.nixosModules.disko

              {
                nixpkgs = {
                  inherit pkgs;
                  overlays = [
                    (_: _: self.packages.${system}) # fix INF
                  ];
                };

                system = {
                  inherit stateVersion;
                };

                networking = {
                  inherit hostName;
                };
              }
            ]
            ++ modules
            ++ modules'.sys;
          };
        };

      mkHomeManager =
        username: hostName:
        {
          mark ? "${username}@${hostName}",
          secrets ? (flake-secrets.lib.hmModule username hostName),
          modules ? [
            (./. + "/home-manager/${mark}")

            secrets.module
          ],
        }:
        let
          sys = self.nixosConfigurations.${hostName};

          sysCfg = sys.config;
        in
        {
          "${mark}" = home-manager.lib.homeManagerConfiguration {
            inherit (sys) pkgs;

            extraSpecialArgs = {
              inherit self sysCfg;
              inherit (secrets) values;
              wmCfg = (self.lib.wm' sysCfg);

              dots = ./dots;
            };
            modules = [
              {
                imports = [ niri.homeModules.config ];

                home = {
                  inherit stateVersion username;

                  homeDirectory = "/home/${username}";
                };
              }
            ]
            ++ modules
            ++ modules'.home;
          };
        };
    in
    {
      overlays.default = import ./flake.overlays.nix;

      lib = import ./lib {
        inherit
          mkPkgs
          mkSystem
          mkHomeManager
          ;
        inherit (nixpkgs) lib;
      };

      nixosConfigurations =
        (mkSystem "nos" { }) // (flake-secrets.nixosConfigurations { inherit (self) lib; });

      homeConfigurations =
        (mkHomeManager "stzx" "nos" { }) // (flake-secrets.homeConfigurations { inherit (self) lib; });
    }
    // flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = (mkPkgs system);
      in
      {
        devShells = import ./flake.shells.nix { inherit pkgs; };

        formatter = pkgs.treefmt;

        packages = pkgs.lib.packagesFromDirectoryRecursive {
          inherit (pkgs) callPackage;
          directory = ./pkgs;
        };
      }
    );
}

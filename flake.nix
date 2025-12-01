{
  description = "NixOS";

  inputs = {
    self.submodules = true;

    systems.url = "github:nix-systems/default-linux";

    stable.url = "git+https://github.com/NixOS/nixpkgs.git?ref=nixos-25.11&shallow=1";
    unstable.url = "git+https://github.com/NixOS/nixpkgs.git?ref=nixos-unstable&shallow=1";

    # nix = {
    #   url = "git+https://github.com/DeterminateSystems/nix-src.git?ref=refs/tags/v3.11.1&shallow=1";
    #   inputs = {
    #     nixpkgs.follows = "nixpkgs";
    #     nixpkgs-23-11.follows = "";
    #     nixpkgs-regression.follows = "";
    #
    #     git-hooks-nix.follows = "";
    #   };
    # };

    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.3";
      inputs.nixpkgs.follows = "unstable";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "unstable";
    };

    home-manager = {
      url = "git+https://github.com/nix-community/home-manager.git?ref=master&shallow=1";
      inputs.nixpkgs.follows = "unstable";
    };

    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.systems.follows = "systems";
    };

    flake-secrets.url = "git+file:../flake-secrets";

    niri = {
      url = "github:sodiboo/niri-flake";
      inputs = {
        nixpkgs.follows = "unstable";
        nixpkgs-stable.follows = "stable";

        niri-stable.follows = "";
        niri-unstable.follows = "";

        xwayland-satellite-stable.follows = "";
        xwayland-satellite-unstable.follows = "";
      };
    };
  };

  outputs =
    {
      self,
      unstable,
      home-manager,
      flake-utils,
      flake-secrets,
      niri,
      ...
    }@args:
    let
      stateVersion = "26.05";

      dots = ./. + "/dots";

      modules' = self.lib.scanModules ./modules;

      mkPkgs =
        system:
        import unstable {
          localSystem = { inherit system; };
          config = {
            allowAliases = false;
            allowUnfree = true;
            permittedInsecurePackages = [
              "python-2.7.18.8"
            ];
          };
          overlays = [
            self.overlays.default

            flake-secrets.overlays.default
          ];
        };

      mkSystem =
        hostName:
        {
          pkgs ? (mkPkgs system),
          system ? "x86_64-linux",
          secrets ? (flake-secrets.lib.nixosModule hostName),
          modules ? [
            args.lanzaboote.nixosModules.lanzaboote

            (./. + "/nixos/${hostName}")
          ],
        }:

        {
          "${hostName}" = unstable.lib.nixosSystem {
            specialArgs = {
              inherit self dots;
              inherit (secrets) values;
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

                system = { inherit stateVersion; };

                networking = { inherit hostName; };
              }

              secrets.module
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
              inherit self dots sysCfg;
              inherit (secrets) values;
            };
            modules = [
              {
                imports = [ niri.homeModules.config ];

                home = {
                  inherit stateVersion username;

                  homeDirectory = "/home/${username}";
                };
              }

              secrets.module
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

        inherit (unstable) lib;
      };

      nixosConfigurations = (mkSystem "nos" { }) // (flake-secrets.nixos args);

      homeConfigurations = (mkHomeManager "stzx" "nos" { }) // (flake-secrets.home args);
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

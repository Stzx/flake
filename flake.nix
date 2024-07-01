{
  description = "NixOS";

  inputs = {
    systems = {
      url = "path:./flake.systems.nix";
      flake = false;
    };

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

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

    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.1";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
    };
  };

  outputs =
    { self
    , nixpkgs
    , home-manager
    , flake-utils
    , flake-secrets
    , ...
    }@args:
    let
      stateVersion = "24.05";

      defaultSystem = "x86_64-linux";

      mkPkgs = system: import nixpkgs {
        localSystem = { inherit system; };
        config = {
          allowAliases = false;
          allowUnfree = true;
        };
        overlays = [
          flake-secrets.overlays.default

          self.overlays.default
        ];
      };

      mkLib = hostName:
        let
          nixos = self.nixosConfigurations.${hostName}.config;

          pkgs = nixos.nixpkgs;
        in
        rec {
          inherit nixos;

          lib = nixpkgs.lib.extend (final: _: rec {
            my = import ./lib { inherit pkgs; lib = final; config = nixos; };
            hm = home-manager.lib.hm;

            inherit (my) attrNeedDE listNeedDE;
          });
        };

      mkHomeManager = username: hostName:
        let
          inherit (mkLib hostName) nixos lib;

          mark = "${username}@${hostName}";

          user = ./. + "/home-manager/${mark}";

          hmSecrets = flake-secrets.lib.hmModule username hostName;
        in
        {
          "${mark}" = home-manager.lib.homeManagerConfiguration
            {
              inherit (nixos.nixpkgs) pkgs;
              inherit lib;

              extraSpecialArgs = {
                inherit (hmSecrets) secrets;
                inherit nixos;
                dotsPath = ./dots;
              };
              modules = [
                ./home-manager
                ./modules/home-manager

                {
                  home = {
                    inherit stateVersion username;

                    homeDirectory = "/home/${username}";
                  };
                }
              ]
              ++ lib.optional (builtins.pathExists user) user
              ++ lib.optional (hmSecrets ? module) hmSecrets.module;
            };
        };

      mkSystem = system: hostName:
        let
          inherit (mkLib hostName) lib;

          osSecrets = flake-secrets.lib.nixosModule hostName;
        in
        {
          "${hostName}" = lib.nixosSystem {
            inherit lib;

            specialArgs = { inherit (osSecrets) secrets; };
            modules = [
              args.disko.nixosModules.disko
              args.lanzaboote.nixosModules.lanzaboote

              ./nixos
              ./modules/nixos
              (./. + "/nixos/${hostName}")

              {
                nixpkgs = { pkgs = mkPkgs system; };

                system = { inherit stateVersion; };

                networking = { inherit hostName; };
              }
            ] ++ lib.optional (osSecrets ? module) osSecrets.module;
          };
        };
    in
    {
      overlays.default = import ./flake.overlays.nix;

      nixosConfigurations = { }
      // mkSystem defaultSystem "nos"
      // mkSystem defaultSystem "vnos";

      homeConfigurations = { }
      // mkHomeManager "stzx" "nos"
      // mkHomeManager "drop" "vnos";

    } // flake-utils.lib.eachDefaultSystem (system: {
      devShells = import ./flake.shells.nix { pkgs = mkPkgs system; };

      formatter = nixpkgs.legacyPackages.${system}.nixpkgs-fmt;
    });
}

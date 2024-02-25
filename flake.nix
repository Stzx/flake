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

    nix-ld = {
      url = "github:Mic92/nix-ld";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-secrets = {
      url = "git+file:./../flake-secrets";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, flake-utils, disko, nix-ld, flake-secrets, ... }:
    let
      stateVersion = "24.05";

      defaultSystem = "x86_64-linux";

      mkPkgs = system: import nixpkgs {
        localSystem = { inherit system; };
        config = {
          allowAliases = false;
          allowUnfree = true;
        };
        overlays = [ self.overlays.default ];
      };

      mkLib = hostName: rec {
        nixos = self.nixosConfigurations.${hostName}.config;

        lib = nixpkgs.lib.extend (final: _: rec {
          my = import ./lib { config = nixos; lib = final; pkgs = nixpkgs; };

          inherit (my) mkDesktopCfg;
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
          "${mark}" = home-manager.lib.homeManagerConfiguration {
            inherit (nixos.nixpkgs) pkgs;
            inherit lib;

            extraSpecialArgs = { inherit (hmSecrets) secrets; inherit nixos; dotsPath = ./dots; };
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
            specialArgs = { inherit (lib) my; inherit (osSecrets) secrets; };
            modules = [
              disko.nixosModules.disko
              nix-ld.nixosModules.nix-ld

              ./nixos
              ./modules/nixos
              (./. + "/nixos/${hostName}")

              {
                nixpkgs = { pkgs = (mkPkgs system); };

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

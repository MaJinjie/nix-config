{
  description = "Nix Configuration with secrets for MacOS and NixOS";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs-wayland = {
      url = "github:nix-community/nixpkgs-wayland";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    darwin = {
      url = "github:LnL7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-homebrew = {
      url = "github:zhaofengli-wip/nix-homebrew";
    };
    homebrew-bundle = {
      url = "github:homebrew/homebrew-bundle";
      flake = false;
    };
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    }; 

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    secrets = {
      url = "git+ssh://git@github.com/majinjie/nix-secrets.git";
      flake = false;
    };
  };
  outputs = { self, darwin, nixpkgs, ... } @inputs:
    let
      user = "majinjie";
      version = "24.11";

      linuxSystems = [ "x86_64-linux" "aarch64-linux" ];
      darwinSystems = [ "aarch64-darwin" "x86_64-darwin" ];
      allSystems = linuxSystems ++ darwinSystems;

      forSystems = systems: f: nixpkgs.lib.genAttrs systems f;

      devShell = system: let pkgs = nixpkgs.legacyPackages.${system}; in {
        default = with pkgs; mkShell {
          nativeBuildInputs = with pkgs; [ bashInteractive git age agenix ];
          shellHook = ''
            export EDITOR=vim
          '';
        };
      };
      mkApp = scriptName: system: {
        type = "app";
        program = "${(nixpkgs.legacyPackages.${system}.writeScriptBin scriptName ''
          #!/usr/bin/env bash
          PATH=${nixpkgs.legacyPackages.${system}.git}/bin:$PATH
          echo "Running ${scriptName} for ${system}"
          exec ${self}/apps/${system}/${scriptName}
        '')}/bin/${scriptName}";
      };
      mkLinuxApps = system: {
        "build-switch" = mkApp "build-switch" system;
      };
      mkDarwinApps = system: {
        "build-switch" = mkApp "build-switch" system;
        "rollback" = mkApp "rollback" system;
      };
    in
    {
      devShells = forSystems allSystems devShell;
      apps = forSystems linuxSystems mkLinuxApps // forSystems darwinSystems mkDarwinApps;

      darwinConfigurations = forSystems darwinSystems (system:
        darwin.lib.darwinSystem rec {
          inherit system;
          specialArgs = inputs // {  inherit user system version; };
          modules = import ./hosts/darwin specialArgs;
        }
      );

      nixosConfigurations = forSystems linuxSystems (system: 
        nixpkgs.lib.nixosSystem rec {
          inherit system;
          specialArgs = inputs // { inherit user system version; };
          modules = import ./hosts/nixos specialArgs;
        }
      );
      formatter = forSystems allSystems (system: nixpkgs.legacyPackages."${system}".nixfmt-rfc-style);
  };
}

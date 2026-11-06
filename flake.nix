{
  description = "Nix Configuration";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    flake-parts.url = "github:hercules-ci/flake-parts";

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko/latest";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    dux-shell = {
      url = "github:duxlabs-dev/dux-shell/stable";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    dux-plugin-registry = {
      url = "github:duxlabs-dev/dux-plugin-registry";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  
  };
  nixSettings = {
    substituters = [
      "https://mirror.sjtu.edu.cn/nix-channels/store"
      "https://cache.nixos.org/"
    ];
  };
  outputs = 
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } ({ inputs, lib, config, ... }: 
    let
      modulesFromDirectoryRecursive = 
        let 
          inherit (lib) concatMapAttrs hasSuffix removeSuffix;
          inherit (builtins) pathExists readDir;

          processDir = 
            { directory, maxDepth }:
            concatMapAttrs (
              name: type:
              let 
                path = directory + "/${name}";
              in 
              if type == "directory" then
                { "${name}" = modulesFromDirectoryRecursive { directory = path; maxDepth = maxDepth - 1; firstStop = true; }; }
              else if type == "regular" && hasSuffix ".nix" name then
                { "${removeSuffix ".nix" name}" = path;}
              else if type == "regular" then
                {}
              else 
                throw "Unknown file type: ${type} for ${path}"
            ) (readDir directory);
        in
        { 
          directory, 
          maxDepth ? 128,
          firstStop ? false 
        }:
        let
          defaultPath = directory + "/default.nix";
        in
        if pathExists defaultPath && firstStop then
          defaultPath
        else if maxDepth > 0 then
          processDir { directory = directory; maxDepth = maxDepth; }
        else
          {};
      
      flattenModulePath = 
        let
          inherit (builtins) isAttrs;
          inherit (lib) foldlAttrs hasPrefix;

          processAttrs = 
            attrs: 
            foldlAttrs (
              acc: name: value:
              if isAttrs value then
                acc // flattenModulePath value
              else
                acc // { "${name}" = value; }
            ) {} attrs;
        in
        processAttrs;

      mkHomeManagerModule =
        configurationName: sharedModules:                  
        {
          home-manager = {                 
            useUserPackages = true;
            useGlobalPkgs = true;
            enableLegacyProfileManagement = false;
            backupFileExtension = "hm.bak";
            sharedModules = [] ++ sharedModules;
            extraSpecialArgs = specialArgs;
          };
        };  
    
      commonConfig = {
        nixpkgs = {
          config = {
            allowUnfree = true;
          };
        };
        nix = {
          settings = {
            experimental-features = [ "nix-command" "flakes" ];
          };
        };
      };

      specialArgs = {
        flake-config = config;
      };
        
      mkNixosSystem =
        configurationName: configurationPath:
        inputs.nixpkgs.lib.nixosSystem {
          modules = [
            configurationPath
            commonConfig            
            (mkHomeManagerModule configurationName [])

            inputs.home-manager.nixosModules.home-manager
            inputs.disko.nixosModules.default
            inputs.dux-shell.nixosModules.default
            inputs.dux-plugin-registry.nixosModules.default
          ];
          specialArgs = specialArgs;
        };
      mkDarwinSystem =
        configurationName: configurationPath:
        inputs.nix-darwin.lib.darwinSystem {
          modules = [
            configurationPath
            commonConfig
            (mkHomeManagerModule configurationName [])

            inputs.home-manager.darwinModules.home-manager
          ];
          specialArgs = specialArgs;
        };
      mkHomeManagerConfiguration =
        configurationName: configurationPath:
        moduleWithSystem ({ pkgs, ... }:
        inputs.home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [
            configurationPath
            commonConfig
          ];
          extraSpecialArgs = specialArgs;
        });

      nixosConfigurations = modulesFromDirectoryRecursive { directory = ./hosts; maxDepth = 1; };
      darwinConfigurations = modulesFromDirectoryRecursive { directory = ./darwin; maxDepth = 1; };
      homeConfigurations = modulesFromDirectoryRecursive { directory = ./home; maxDepth = 1; };

      nixosModules = modulesFromDirectoryRecursive { directory = ./modules/nixos; };
      darwinModules = modulesFromDirectoryRecursive { directory = ./modules/darwin; };
      homeModules = modulesFromDirectoryRecursive { directory = ./modules/home; };
      flakeModules = modulesFromDirectoryRecursive { directory = ./modules/flake; };
    in
    {
      imports = [
        inputs.home-manager.flakeModules.home-manager
        flakeModules.nix-darwin
        flakeModules.config
        ./flake-config.nix
      ];
      systems = [
        "x86_64-linux"
      ];
      flake = {
        nixosConfigurations = builtins.mapAttrs mkNixosSystem nixosConfigurations;
        darwinConfigurations = builtins.mapAttrs mkDarwinSystem darwinConfigurations;
        homeConfigurations = builtins.mapAttrs mkHomeManagerConfiguration homeConfigurations;

        nixosModules = flattenModulePath nixosModules;
        darwinModules = flattenModulePath darwinModules;
        homeModules = flattenModulePath homeModules;
        flakeModules = flattenModulePath flakeModules;
      }
    });
}
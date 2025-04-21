{ user, home-manager, disko, agenix,  ... }@extraArgs: 

[
  ./configuration.nix
  ../../modules/shared

  disko.nixosModules.default
  ../../modules/nixos/disko.nix

  home-manager.nixosModules.default
  {
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      extraSpecialArgs = extraArgs;
      users.${user} = import ../../modules/nixos/home-manager.nix;
    };
  }

  agenix.nixosModules.default
  ../../modules/nixos/agenix.nix
]

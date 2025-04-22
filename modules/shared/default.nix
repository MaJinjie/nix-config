{ system, nixpkgs-wayland, agenix, ... }:

{
  # nixpkgs settings
  nixpkgs = {
    hostPlatform = system;
    config = {
      allowUnfree = true;
    };
    overlays = [ 
      agenix.overlays.default

      nixpkgs-wayland.overlays.default
    ];
  };
}

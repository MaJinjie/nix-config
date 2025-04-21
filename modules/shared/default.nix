{ system, nixpkgs-wayland, agenix, ... }:

{
  # nixpkgs settings
  nixpkgs = {
    hostPlatform = system;
    config = {
      allowUnfree = true;
    };
    overlays = let path = ../../overlays; in [
      agenix.overlays.default

      nixpkgs-wayland.overlay.default
      (
        builtins.map 
          (n: import (path + ("/" + n)))
          (
            builtins.filter 
              (n: builtins.match ".*\\.nix" n != null || builtins.pathExists (path + ("/" + n + "/default.nix")))
              (builtins.attrNames (builtins.readDir path))
          )
      )
    ];
  };
}

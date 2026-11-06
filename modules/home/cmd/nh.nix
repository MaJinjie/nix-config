{ flake-config, lib, ... }:
let 
  inherit (flake-config) root;
in 
{
  programs.nh = {
    enable = lib.mkDefault true;
    flake = root;
    clean = {
      enable = true;
      dates = "weekly";
      extraArgs = "--keep 5 --keep-since 3d";
    };
  };
}
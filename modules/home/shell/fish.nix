{ lib, ... }:
{
  imports = [ 
    ./scripts/z-lua.nix 
  ];
  
  programs.fish = {
    enable = lib.mkDefault true;
  };
}
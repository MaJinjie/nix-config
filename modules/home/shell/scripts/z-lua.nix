{ config, lib, ... }:
let 
  inherit (lib) mkBefore mkOrder mkAfter;

  inherit (config.programs) bash zsh fish z-lua;
in 
{
  programs.z-lua = {
    enable = lib.mkDefault true;
    options = [ "enhanced" "once" ];
  };

  programs.fish = lib.mkIf (fish.enable) (lib.mkMerge [
    (lib.mkIf (z-lua.enable) {
      shellInit = mkBefore ''
        set -g _Z_CMD c
      '';
    })
  ]);
}
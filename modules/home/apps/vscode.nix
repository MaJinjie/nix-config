{ lib, config, pkgs, ... }:
{
  programs.vscode = {
    enable = lib.mkDefault true;
    mutableExtensionsDir = true;
    profiles.default = {
      extensions = with pkgs.vscode-extensions; [
        jnoortheen.nix-ide
      ];
      mutableUserSettings = true;
    };
  };
}
{ lib, config, pkgs, ... }:
{
  programs.vscode = {
    enable = lib.mkDefault true;
    mutableExtensionsDir = true;
  };
}
{ lib, ... }:
{
  programs.ripgrep = {
    enable = lib.mkDefault true;
  };
}
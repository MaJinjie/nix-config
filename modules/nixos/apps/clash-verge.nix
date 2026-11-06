{ lib, ... }:
{
  programs.clash-verge = {
    enable = lib.mkDefault true;
    serviceMode = true;
    tunMode = true;
    autoStart = false;
  };
}
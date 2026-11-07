{ lib, ... }:
{
  programs.yazi = {
    enable = lib.mkDefault true;
    shellWrapperName = "cy";
  };
}
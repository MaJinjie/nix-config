{ lib, ... }:
{
  programs.eza = {
    enable = lib.mkDefault true;
    extraOptions = [
      "--icons"
      "--classify=auto"
    ];
  };
}
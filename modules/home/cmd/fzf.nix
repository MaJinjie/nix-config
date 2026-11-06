{ lib, ... }:
{
  programs.fzf = {
    enable = lib.mkDefault true;
    defaultOptions = [
      "--pointer='>'"
      "--marker='▍'"
      "--scrollbar='█'"
      "--info=inline"
      "--cycle"
      "--ansi"
      "--tabstop=2"
    ];
  };
}
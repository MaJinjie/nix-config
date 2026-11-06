{ flake-config, lib, config, pkgs, ... }:
let
  cfg = config.programs.neovim;
in
{
  programs.neovim = {
    enable = lib.mkDefault true;
    defaultEditor = lib.mkDefault true;
    sideloadInitLua = true;

    plugins = with pkgs.vimPlugins; [

    ];

    extraPackages = with pkgs; [
      lua-language-server stylua
      nil nixd nixfmt
    ];
  };

  programs.neovide = {
    enable = lib.mkIf cfg.enable (lib.mkDefault true);
  };
}
{ flake-config, pkgs, ... }:
let 
  inherit (flake-config) user;
  inherit (flake-config) nixosModules homeModules;
{
  imports = with nixosModules; [
    dux-shell
    clash-verge
  ] ++ [
    ./configuration.nix
    ./hardware-configuration.nix
    ./disko-config.nix
  ];

  users.users.default = {
    name = "${user}";
    isNormalUser = true;
    shell = pkgs.fish;
  };

  home-manager.users.default = {
    imports = with homeModules; [
      bat
      eza
      fd
      fzf
      git
      nh
      ripgrep
      neovim
      input
      fish
      tmux

      symlinks
    ];
  };
}
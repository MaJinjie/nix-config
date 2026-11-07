{ flake-config, pkgs, ... }:
let 
  inherit (flake-config) user stateVersion;
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
    extraGroups = [ "wheel" ];
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
      input
      fish
      tmux
      neovim
      vscode

      symlinks
    ] ++ [
      ./home-manager-config.nix
    ];

    inherit stateVersion;
  };

  inherit stateVersion;
}

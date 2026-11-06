{ flake-config, lib, config, ... }:
let 
  inherit (flake-config) user;
in 
{
  programs.git = {
    enable = lib.mkDefault true;
    settings = {
      user = { inherit (user) name email; };
    };
    ignores = [
      "*~"
      "*.swp"
      "*.bak"
    ];
    lfs.enable = lib.mkDefault true;
  };

  programs.delta = {
    enable = lib.mkIf config.programs.git.enable (lib.mkDefault true);
    enableGitIntegration = true;
  };
  programs.lazygit = {
    enable = lib.mkIf config.programs.git.enable (lib.mkDefault true);
  };
}

{ user, version, pkgs, config, lib, ... }: 

{

  home = {
    stateVersion = version;
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    withNodeJs = true;
    withPython3 = true;
    withRuby = true;
    extraPackages = with pkgs; [
      stylua lua-language-server
      nil nixfmt-rfc-style
    ];
  };
  programs.neovide = {
    enable = true;
    settings = {};
  };
}

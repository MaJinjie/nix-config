{ pkgs, config, lib, ... }: 

{
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
  };

  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
    extraPackages = with pkgs; [
      swaybg
      brightnessctl
      swayidle
      swaylock
      tlp
      wmenu
      dunst
      foot
    ];
  };

  programs.firefox = {
    enable = true;
    package = pkgs.wrapFirefox (pkgs.firefox-unwrapped.override {pipewireSupport = true;}) {};
  };

  programs.clash-verge = {
    enable = true;
    autoStart = true;
  };
}

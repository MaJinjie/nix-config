{ pkgs, ... }:

{
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

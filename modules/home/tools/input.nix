{ lib, pkgs, ... }:
{
  i18n.inputMethod.enable = lib.mkDefault true;
  i18n.inputMethod.type = lib.mkDefault "fcitx5";
  
  i18n.inputMethod.fcitx5 = {
    waylandFrontend = true;
    addons = with pkgs; [
      fcitx5-gtk
      kdePackages.fcitx5-qt
      qt6Packages.fcitx5-chinese-addons
      (fcitx5-rime.override { rimeDataPkgs = [ rime-ice ]; })
      catppuccin-fcitx5
    ];
  };
}
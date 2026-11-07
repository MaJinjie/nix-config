{ flake-config, lib, config, ... }:
let
  inherit (flake-config) user;
in
{
  programs.dank-material-shell = {
    enable = lib.mkDefault true;
    systemd.enable = true;

    enableSystemMonitoring = true;     # System monitoring widgets (dgop)
    enableVPN = true;                  # VPN management widget
    enableDynamicTheming = true;       # Wallpaper-based theming (matugen)
    enableAudioWavelength = true;      # Audio visualizer (cava)
    enableCalendarEvents = true;       # Calendar integration (khal)
  };

  services.displayManager.dux-greeter = {
    enable = lib.mkDefault true;
    compositor.name = lib.mkDefault "niri";
    configHome = lib.mkDefault "/home/${user}";
  };

  programs.niri = {
    enable = lib.mkDefault true;
    useNautilus = false;
  };

  programs.dux-files = {
    enable = lib.mkDefault true;
    systemd.enable = true;
    portal.enable = true;
  };
  xdg.portal.config."niri"."org.freedesktop.impl.portal.FileChooser" = lib.mkIf (config.programs.dux-files.portal.enable) [ "dfiles" ];

  programs.dux-search = {
    enable = lib.mkDefault true;
    systemd.enable = true;
  };

  programs.foot = {
    enable = lib.mkDefault true;
    xdg.serverAutostart = true;
  };

  programs.firefox = {
    enable = lib.mkDefault true;
  };

  programs.neovim = {
    enable = lib.mkDefault true;
    defaultEditor = true;
    vimAlias = true;
  };
}
{ flake-config, lib, ... }:
let 
  inherit (flake-config) root;
in 
{
  programs.tmux = {
    enable = lib.mkDefault true;

    terminal = "tmux-256color";
    shortcut = ",";
    keyMode = "vi";
    mouse = true;
    focusEvents = true;
    clock24 = true;
    baseIndex = 1;
    escapeTime = 5;

    # Disable tmux-sensible plugin
    sensibleOnTop = false;
    # Store tmux socket in /run/user/<UID>
    secureSocket = true;

    tmuxinator.enable = true;
  };
  xdg.configFile."tmux/tmux.conf".target =  "tmux/tmux.hm.conf";
}

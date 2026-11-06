{ flake-config, config, lib, ... }:
let
  inherit (flake-config) root;

  mkSymlinks = lib.mapAttrs' (
    target: source: lib.nameValuePair "_${target}_" {
      source = config.lib.file.mkOutOfStoreSymlink "${root}/dotfiles/.config/${source}";
      inherit target;
    }
  );
in
{
  xdg.configFile = mkSymlinks {
    "nvim" = "nvim";
    "niri" = "niri";
    "tmux/tmux.conf" = "tmux/tmux.conf";
  };
}
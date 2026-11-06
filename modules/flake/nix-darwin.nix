{ self, lib, moduleLocation, ... }:
let
  inherit (lib)
    mapAttrs
    mkOption
    types
    ;
in
{
  options = {
    flake.darwinConfigurations = mkOption {
      type = types.lazyAttrsOf types.raw;
      default = { };
      description = ''
        Instantiated Darwin configurations. Used by `darwin-rebuild`.

        `darwinConfigurations` is for specific installations. If you want to expose
        reusable configurations, add them to [`darwinModules`](#opt-flake.darwinModules)
        in the form of modules (no `lib.darwinSystem`), so that you can reference
        them in this or another flake's `darwinConfigurations`.
      '';
    };
    flake.darwinModules = mkOption {
      type = types.lazyAttrsOf types.deferredModule;
      default = { };
      apply = mapAttrs (k: v: {
        _class = "darwin";
        _file = "${toString moduleLocation}#darwinModules.${k}";
        imports = [ v ];
      });
      description = ''
        Darwin modules.

        You may use this for reusable pieces of configuration, service modules, etc.
      '';
    };
  };
}
{ lib, ... }:
let
  inherit (lib) mkOption types;
in
{
  options = {
    root = mkOption {
      type = types.str;
      description = "Where is the position of current flake";
    };
    user = mkOption {
      type = types.submodule { 
        options = {
          shortName = mkOption {
            type = types.str;
            description = "Use the short name for user";
          };
          name = mkOption {
            type = types.str;
            description = "Use the full name for user";
          };
          email = mkOption {
            type = types.str;
            description = "Use the email address for user";
          };
        };
        config = {
          __toString = self: self.shortName;
        };
      };
    };
    stateVersion = mkOption {
      type = types.str;
      description = "This option defines the first version you have installed on this particular machine.";
    };
  };
}

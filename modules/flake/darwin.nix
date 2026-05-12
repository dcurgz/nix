{
  inputs,
  lib,
  ...
}:

{
  # This is required as flake-parts does not have a builtin define for flake.darwinConfigurations.
  options = {
    flake.darwinConfigurations = lib.mkOption {
      type = lib.types.lazyAttrsOf lib.types.raw;
      default = { };
      description = ''
        Instantiated Darwin configurations. Used by `darwin-rebuild`.
      '';
    };
  };
}

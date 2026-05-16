{
  inputs,
  lib,
  ...
} @args:

let
  inherit (args.config) flake; 
  unspecified = lib.mkOption {
    type = lib.types.attrsOf (lib.types.attrsOf lib.types.anything);
    default = { };
  };

  # These options are duplicated through each configuration class.
  commonOptions = {
    git-secrets = unspecified;
    keys = unspecified;
  };
  moduleOptions = {
    host-constants = lib.mkOption { type = lib.types.anything; };
  };
in
{
  # These options are in global (flake-parts class) scope.
  options.by = commonOptions;

  config = {
    flake.modules.nixos.flake-options = flake.lib.nixos.mkAspect (with flake.tags; [ flake-default ])
      (_args:

      {
        options.by = commonOptions // moduleOptions;
      });

    flake.modules.darwin.flake-options = flake.lib.darwin.mkAspect (with flake.tags; [ flake-default ])
      (_args:
      {
        options.by = commonOptions // moduleOptions;
      });

    flake.modules.home-manager.flake-options = flake.lib.home-manager.mkAspect (with flake.tags; [ flake-default ])
      (_args:

      {
        options.by = commonOptions // moduleOptions;
      });
  };
}

{
  inputs,
  lib,
  ...
}:

{
  options = {
    flake.deploy.nodes = lib.mkOption {
      type = lib.types.lazyAttrsOf lib.types.raw;
      default = { };
      description = ''
        deploy-rs configuration flake output.
      '';
    };
  };
}

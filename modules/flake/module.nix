{
  inputs,
  lib,
  ...
}:

{
  options.flake.modules = lib.mkOption {
    type = lib.types.attrsOf lib.types.anything;
    default = { };
  };
}

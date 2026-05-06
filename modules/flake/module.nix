{
  inputs,
  lib,
  ...
}:

let
  anything = lib.mkOption {
    type = lib.types.attrsOf lib.types.anything;
    default = { };
  };
in
{
  options.flake.modules ={
    nixos = anything;
    darwin = anything;
    home-manager = anything;
    generic = anything;
  };
}

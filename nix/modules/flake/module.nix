{
  inputs,
  lib,
  ...
}:

let
  option = lib.mkOption {
    type = lib.types.attrsOf lib.types.raw;
    default = { };
    description = ''
      An attrset of module definitions. A module can be a function or an Aspect
      i.e. instantiated via flake.lib's mkAspect.
    '';
  };
in
{
  options.flake.modules = {
    nixos        = option;
    darwin       = option;
    home-manager = option;
    generic      = option;
  };
}

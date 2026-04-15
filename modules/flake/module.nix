{
  inputs,
  ...
}:

let
  inherit (inputs.nixpkgs) lib;
in
{
  options.flake.modules = lib.mkOption {
    type = lib.types.attrsOf (lib.types.attrsOf lib.types.unspecified);
    default = lib.mkOption { };
  };
}

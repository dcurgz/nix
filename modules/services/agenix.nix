{
  inputs,
  ...
} @args:
let
  inherit (args.config) flake;
in

{
  flake.modules.nixos.agenix = flake.lib.nixos.mkAspect (with flake.tags; [ nixos-base ])
  ({
    lib,
    ...
  }:

  {
    imports = [
      inputs.agenix.nixosModules.default
    ];
  });
}

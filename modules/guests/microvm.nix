{
  inputs,
  ...
} @args:
let
  inherit (args.config) flake;
in

{
  flake.modules.nixos.microvm = flake.lib.nixos.mkAspect (with flake.tags; [ ])
    ({
      lib,
      config,
      ...
    }:

    {
      imports = [
        inputs.microvm.nixosModules.host
      ];
    });
}

{
  inputs,
  ...
} @args:
let
  inherit (args.config) flake;
in

{
  flake.modules.nixos.linux-sudo = flake.lib.nixos.mkAspect []
    ({
      lib,
      config,
      ...
    }:

    {
       # Enable sudo.
       security.sudo = {
         enable = true;
         # TODO: use some kind of auth for this
         wheelNeedsPassword = false;
       };
    });
}

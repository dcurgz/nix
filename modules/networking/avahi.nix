{
  inputs,
  ...
} @args:
let
  inherit (args.config) flake;
in

{
  flake.modules.nixos.avahi = flake.lib.nixos.mkAspect (with flake.tags; [ nixos-base ])
    ({
      lib,
      config,
      ...
    }:

    {
      services.avahi = {
        enable = true;
        nssmdns4 = true;
        nssmdns6 = false;
        publish = {
          enable = true;
          addresses = true;
          workstation = true;
        };
      };
    });
}

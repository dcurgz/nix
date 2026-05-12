{
  inputs,
  ...
} @args:
let
  inherit (args.config) flake;
in

{
  flake.modules.nixos.matter = flake.lib.nixos.mkAspect []
    ({
      lib,
      config,
      ...
    }:

    let
      by = config.by.host-constants;
    in
    {
      services.matter-server = {
        enable = true;
        openFirewall = true;
        extraArgs = [
          "--primary-interface"
          by.hardware.interfaces.wifi
        ];
      };
    });
}

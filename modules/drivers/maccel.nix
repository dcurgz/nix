{
  inputs,
  config,
  ...
}:

let
  inherit (config) flake;
in
{
  flake.modules.nixos.drivers-maccel = flake.lib.nixos.mkAspect []
    ({
      lib,
      config,
      ...
    }:

    {
      imports = [
        inputs.maccel.nixosModules.default
      ];

      hardware.maccel = {
        enable = true;
        enableCli = true; # Optional: for parameter discovery
        parameters = {
          sensMultiplier = 0.5;
          mode = "natural";
          decayRate = 0.0275;
          offset = 0.5;
          limit = 2.0;
        };
      };
    });
}

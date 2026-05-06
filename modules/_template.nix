{
  inputs,
  ...
} @args:
let
  inherit (args.config) flake;
in

{
  flake.modules.nixos.___ = flake.lib.nixos.mkAspect []
    ({
      lib,
      config,
      ...
    }:

    {

    });

  flake.modules.darwin.___ = flake.lib.darwin.mkAspect []
    ({
      lib,
      config,
      ...
    }:

    {

    });

  flake.modules.home-manager.___ = flake.lib.home-manager.mkAspect []
    ({
      lib,
      config,
      ...
    }:

    {

    });

  flake.modules.generic.___ = flake.lib.generic.mkAspect []
    ({
      lib,
      config,
      ...
    }:

    {

    });
}

{
  inputs,
  ...
} @args:
let
  inherit (args.config) flake;
  hostName = "airberry";
in

{
  flake.modules.darwin.airberry-hardware = flake.lib.darwin.mkAspect []
    ({
      lib,
      config,
      ...
    }:

    {
      config.by.host-constants.hostName = hostName;
    });

  flake.modules.home-manager.airberry-hardware = flake.lib.home-manager.mkAspect []
    ({
      lib,
      config,
      ...
    }:

    {
      config.by.host-constants.hostName = hostName;
    });
}

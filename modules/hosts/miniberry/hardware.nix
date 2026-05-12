{
  inputs,
  ...
} @args:
let
  inherit (args.config) flake;
  hostName = "miniberry";
in

{
  flake.modules.darwin.miniberry-hardware = flake.lib.darwin.mkAspect []
    ({
      lib,
      config,
      ...
    }:

    {
      config.by.host-constants.hostName = hostName;
    });

  flake.modules.home-manager.miniberry-hardware = flake.lib.home-manager.mkAspect []
    ({
      lib,
      config,
      ...
    }:

    {
      config.by.host-constants.hostName = hostName;
    });
}

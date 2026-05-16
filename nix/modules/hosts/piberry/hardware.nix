{
  inputs,
  ...
} @args:

let
  inherit (args.config) flake;
in
{
  flake.modules.nixos.piberry-hardware = flake.lib.nixos.mkAspect []
    ({
      lib,
      ...
    }:

    {
      hardware.enableRedistributableFirmware = true;
      nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";

      by.host-constants.hardware = {
        interfaces.wifi = "wlan0";
      };
    });
}

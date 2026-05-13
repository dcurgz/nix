{
  inputs,
  lib,
  globals,
  ...
} @args:

let
  inherit (args.config) flake;
  inherit (globals) FLAKE_ROOT;

  hostName = "vm-mb-build-aarch64";
in
{
  flake.modules.darwin.${hostName} = flake.lib.darwin.mkMicroVM rec {
      enable = true;
      inherit hostName;
      system = "aarch64-linux";
      extraModules = [
        ### aspects
        ### 3rd party modules
        inputs.agenix.nixosModules.default
      ];
      microvmConfig = {
        networking = {
          macAddress = "02:00:00:00:00:12";
        };
        tailscale = {
          enable = true;
          autologin = true;
        };
      };
      tags = with flake.tags; [ ];
    }

    ({
      config,
      pkgs,
      ...
    }:

    {
      microvm.vcpu = 10;
      microvm.mem = 1024 * 12 + 1;

      nix.channel.enable = false;
    });
}

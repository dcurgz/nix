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
          #ipAddress = "10.0.3.2";
          #ipSubnet = "24";
          #gateway = "10.0.3.1";
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
      microvm.vcpu = 4;
      microvm.mem = 1024 * 6 + 1;
      microvm.shares = [
        # rw-store
        #{
        #  source = "/var/lib/microvms/${hostName}/rw-store";
        #  mountPoint = "/nix/.rw-store";
        #  tag = "rw-store";
        #  proto = "virtiofs";
        #}
      ];
      microvm.writableStoreOverlay = "/nix/.rw-store";

      nix.channel.enable = false;

      networking.firewall.allowedTCPPorts = [
        22
      ];
    });
}

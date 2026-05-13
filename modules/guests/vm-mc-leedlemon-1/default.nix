{
  inputs,
  lib,
  globals,
  ...
} @args:

let
  inherit (args.config) flake;
  inherit (globals) FLAKE_ROOT;

  hostName = "vm-mc-leedl-sta";
  dataDir = "/data/minecraft-leedlemon_staging";
  version = "v5-staging";
in
{
  flake.modules.nixos.${hostName} = flake.lib.nixos.mkMicroVM
    rec {
      inherit hostName;
      system = "x86_64-linux";
      extraModules = [
        ### aspects
        ### 3rd party modules
        inputs.agenix.nixosModules.default
        inputs.neoforge-1-21-1.nixosModules.x86_64-linux.default
      ];
      microvmConfig = {
        networking = {
          macAddress = "02:00:00:00:00:13";
          ipAddress = "10.0.0.23";
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

    let
      inherit (pkgs.by.lib) replaceOptionalVars;
    in
    {
      microvm.vcpu = 3;
      microvm.mem = 1024 * 10;
      microvm.shares = [
        {
          source = dataDir;
          mountPoint = dataDir;
          tag = "minecraft-data";
          proto = "virtiofs";
        }
        # SSL certificates
        {
          source = "/etc/ssl/certs";
          mountPoint = "/etc/ssl/certs";
          tag = "ssl-certs";
          proto = "virtiofs";
          socket = "ssl-certs.sock";
        }
      ];

      networking.firewall.allowedTCPPorts = [ 25565 ];
      networking.firewall.allowedUDPPorts = [ 25565 ];

      environment.systemPackages = with pkgs; [
        jre_headless
        rcon-cli
      ];

      minecraft.neoforge = {
        enable = true;
        package = pkgs.by.neoforge-1-21-1;
        overlays = {
          modpack = pkgs.by.modpack-leedlemon."${version}";
          config = pkgs.linkFarm "config-overlay" [
            {
              name = "server.properties";
              path = replaceOptionalVars ./server.properties {
                inherit version;
              };
            }
          ];
        };
        dataDir = dataDir;
      };

      # Ensure that tailscaled is not terminated before the server shuts down.
      systemd.services.neoforge-server = {
        after = [ "tailscaled.service" ];
        serviceConfig = {
          Requires = [ "tailscaled.service" ];
        };
      };

      users.users.minecraft.extraGroups = [ "data" ];
    });
}

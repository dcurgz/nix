{
  inputs,
  lib,
  globals,
  ...
} @args:

let
  inherit (args.config) flake;
  inherit (globals) FLAKE_ROOT;

  hostName = "vm-mc-slime-0";
  dataDir = "/data/minecraft-slime";
  version = "v5";
in
{
  flake.modules.nixos.${hostName} = flake.lib.nixos.mkMicroVM
    rec {
      enable = true;
      inherit hostName;
      system = "x86_64-linux";
      extraModules = [
        inputs.neoforge-1-21-1.nixosModules.${system}.default
        ### 3rd party modules
        inputs.agenix.nixosModules.default
      ];
      microvmConfig = {
        networking = {
          macAddress = "02:00:00:00:00:06";
          ipAddress = "10.0.0.16";
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
      microvm.vcpu = 6;
      microvm.mem = 1024 * 16;
      microvm.shares = [
        {
          source = dataDir;
          mountPoint = dataDir;
          tag = "minecraft-data";
          proto = "virtiofs";
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
          modpack = pkgs.by.modpack-slime."${version}";
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

      users.users.minecraft.extraGroups = [ "data" ];
    });
}

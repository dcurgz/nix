{
  inputs,
  lib,
  globals,
  ...
} @args:

let
  inherit (args.config) flake;
  inherit (globals) FLAKE_ROOT;

  hostName = "vm-mc-wg-0";
  dataDir = "/data/minecraft-wg-0";
in
{
  flake.modules.nixos.${hostName} = flake.lib.mkMicroVM
    rec {
      inherit hostName;
      system = "x86_64-linux";
      extraModules = [
        ### aspects
        ### 3rd party modules
        inputs.agenix.nixosModules.default
        inputs.nix-minecraft.nixosModules.minecraft-servers
      ];
      microvmConfig = {
        networking = {
          macAddress = "02:00:00:00:00:01";
          ipAddress = "10.0.0.11";
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
      microvm.vcpu = 12;
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
        javaPackages.compiler.temurin-bin.jre-17
        rcon-cli
      ];

      users.users.minecraft = {
        isSystemUser = true;
        group = "minecraft";
        extraGroups = [ "data" ];
      };
      users.groups.minecraft = {};

      systemd.services.minecraft =
        let
          serverPath = "${dataDir}/wg-forge-1.20.1/";
        in
        {
          enable = true;
          after = [ "network-online.target" ];
          wants = [ "network-online.target" ];
          wantedBy = [ "multi-user.target" ];
          serviceConfig = {
            Restart = "always";
            RestartSec = "5s";
            WorkingDirectory = serverPath;
            User = "minecraft";
          };
          path = [ pkgs.bash pkgs.javaPackages.compiler.temurin-bin.jre-17 ];
          script = ''
            #!/usr/bin/env bash
            set -xe
            bash ./run.sh
          '';
        };
    });
}

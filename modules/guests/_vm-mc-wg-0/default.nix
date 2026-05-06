{
  config,
  lib,
  pkgs,
  inputs,
  globals,
  ...
}:

let
  by = config.by.constants;
  inherit (globals) FLAKE_ROOT NIXOS_PRESETS;

  hostname = "vm-mc-wg-0";
  nix-minecraft = inputs.nix-minecraft;
  fabricServers = nix-minecraft.legacyPackages.x86_64-linux.fabricServers;

  dataDir = "/data/minecraft-wg-0";
in
{
  hyperberry.virtualization = {
    vms.${hostname} = {
      networking = {
        macAddress = "02:00:00:00:00:01";
        ipAddress = "10.0.0.11";
      };
      microvm = {
        extraModules = [
          inputs.agenix.nixosModules.default
          inputs.nix-minecraft.nixosModules.minecraft-servers
        ];
        config = { config, ... }: {
          imports = [
            "${NIXOS_PRESETS}/packages/core"
            "${NIXOS_PRESETS}/security/groups"
          ];

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

          age.secrets.tailscale-auth-key = {
            file = "${FLAKE_ROOT}/secrets/tailscale/guests/${hostname}.age"; 
            mode = "0440"; 
          };
          services.tailscale.authKeyFile = config.age.secrets.tailscale-auth-key.path;
        };
      };

    };
  };
}

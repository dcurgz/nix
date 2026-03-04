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
  inherit (globals) NIXOS_PRESETS;

  hostname = "vm-teamspeak";
  data = "/data/teamspeak";
in
{
  hyperberry.virtualization = {
    vms.${hostname} = {
      networking = {
        macAddress = "02:00:00:00:00:05";
        ipAddress = "10.0.0.15";
      };
      microvm = {
        pkgs = (import inputs.nixpkgs {
          system = "x86_64-linux";
          config.allowUnfree = true;
        });
        config = {
          imports = [
            "${NIXOS_PRESETS}/packages/core"
            "${NIXOS_PRESETS}/security/groups"
            "${NIXOS_PRESETS}/containers/teamspeak6-server"
          ];

          microvm.vcpu = 4;
          microvm.mem = 1024 * 6 + 1;
          microvm.shares = [
            {
              source = data;
              mountPoint = "/var/lib/teamspeak6-server";
              tag = "teamspeak-data";
              proto = "virtiofs";
              socket = "teamspeak-data.sock";
            }
          ];

          users.users.teamspeak.extraGroups = [ "data" ];

          nix.channel.enable = false;

          # Immich-specific packages
          environment.systemPackages = with pkgs; [
            podman-tui
          ];

          # Additional firewall ports for immich
          networking.firewall.allowedTCPPorts = [
            22
            30033
            10011
            10022
            10080
            10443
            41144
          ];
          networking.firewall.allowedUDPPorts = [
            9987
          ];
        };
      };
    };
  };
}

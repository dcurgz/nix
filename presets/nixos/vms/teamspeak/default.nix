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
      enable = true;

      vcpus = 4;
      memory = 1024 * 6 + 1;

      networking = {
        macAddress = "02:00:00:00:00:05";
        ipAddress = "10.0.0.15";
      };

      # Allow unfree packages for this VM
      nixpkgsConfig = {
        config.allowUnfree = true;
      };

      # Additional tmpfiles for immich data directories
      tmpfiles = [ "d ${data} - 9987 9987 - -" ];

      # Additional shares beyond the common ones
      mounts = [
        {
          source = data;
          mountPoint = "/var/lib/teamspeak6-server";
          tag = "teamspeak-data";
          proto = "virtiofs";
          socket = "teamspeak-data.sock";
        }
      ];

      # VM-specific configuration
      config = {
        imports = [
          "${NIXOS_PRESETS}/packages/core"
          "${NIXOS_PRESETS}/containers/teamspeak6-server"
        ];

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
}

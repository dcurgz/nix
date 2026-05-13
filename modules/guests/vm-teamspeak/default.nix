{
  inputs,
  lib,
  globals,
  ...
} @args:

let
  inherit (args.config) flake;
  inherit (globals) FLAKE_ROOT;

  hostName = "vm-teamspeak";
  data = "/data/teamspeak";

  teamspeakVersion = "v6.0.0-beta7";
in
{
  flake.modules.nixos.${hostName} = flake.lib.nixos.mkMicroVM
    rec {
      enable = true;
      inherit hostName;
      system = "x86_64-linux";
      extraModules = [
        ### aspects
        ### 3rd party modules
        inputs.agenix.nixosModules.default
        # TODO: re-add teamspeak6-server container preset
        #"${NIXOS_PRESETS}/containers/teamspeak6-server"
      ];
      microvmConfig = {
        networking = {
          macAddress = "02:00:00:00:00:05";
          ipAddress = "10.0.0.15";
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
        {
          source = data;
          mountPoint = "/var/lib/teamspeak6-server";
          tag = "teamspeak-data";
          proto = "virtiofs";
          socket = "teamspeak-data.sock";
        }
      ];

      virtualisation.oci-containers.containers = {
        teamspeak = {
          image = "teamspeaksystems/teamspeak6-server:${teamspeakVersion}";
          autoStart = true;

          user = "teamspeak:nogroup";

          dependsOn = [];

          #ports = [
          #  # Bind for VPS
          #  "9987:9987/udp" # Voice port
          #  "30033:30033" # File transfer
          #  "10080:10080/tcp" # Web query
          #];

          volumes = [
            "/var/lib/teamspeak6-server:/var/tsserver"
          ];

          environment = {
            TZ = "Europe/London";
            TSSERVER_LICENSE_ACCEPTED = "accept";
          };

          extraOptions = [
            "--network=host"
          ];
        };
      };

      users.users.teamspeak = {
        isSystemUser = true;
        group = "teamspeak";
        extraGroups = [ "data" ];
      };
      users.groups.teamspeak = {};

      nix.channel.enable = false;

      environment.systemPackages = with pkgs; [
        podman-tui
      ];

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
    });
}

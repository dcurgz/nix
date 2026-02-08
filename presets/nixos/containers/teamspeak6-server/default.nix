# https://github.com/ChUrl/flake-nixinator/blob/cec5ec5493940733310b7f6ac414320b6b27d945/system/services/teamspeak.nix#L11
{
  config,
  lib,
  pkgs,
  ...
}:
let
  teamspeakVersion = "v6.0.0-beta7";
in {
  users.users.teamspeak = {
    isSystemUser = true;
    group = "teamspeak";
  };
  users.groups.teamspeak = {};

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
}

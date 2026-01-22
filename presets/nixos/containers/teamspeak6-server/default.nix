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
  virtualisation.oci-containers.containers = {
    teamspeak = {
      image = "teamspeaksystems/teamspeak6-server:${teamspeakVersion}";
      autoStart = true;

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
        PUID = "1000";
        PGID = "1000";
        TZ = "Europe/London";

        TSSERVER_LICENSE_ACCEPTED = "accept";
      };

      extraOptions = [
        "--network=host"
      ];
    };
  };
}

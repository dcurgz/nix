{ config, lib, pkgs, ... }: 

let
  ha_config = pkgs.writeText "configuration.yaml" ''
    http:
      server_host: "::1"
      trusted_proxies: "::1"
      use_x_forwarded_for: true
  '';
in
{  
  virtualisation.containers.enable = true;
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    defaultNetwork.settings.dns_enabled = true;
  };

  virtualisation.oci-containers = {
    backend = "podman";
    containers.home-assistant = {
      volumes = [
        "/data/home-assistant:/config"
      ];
      environment.TZ = "Europe/London";
      # Note: The image will not be updated on rebuilds, unless the version label changes
      image = "ghcr.io/home-assistant/home-assistant:stable";
      extraOptions = [ 
        # Use the host network namespace for all sockets
        "--network=host"
        #https://github.com/home-assistant/core/issues/62188
        "--cap-add=CAP_NET_RAW,CAP_NET_BIND_SERVICE"
        # Pass devices into the container, so Home Assistant can discover and make use of them
        #"--device=/dev/ttyACM0:/dev/ttyACM0"
      ];
    };
  };

  environment.systemPackages = with pkgs; [
    dive
    podman-tui
    docker-compose
    podman-compose
  ];
}

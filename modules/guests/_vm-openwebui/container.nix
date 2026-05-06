{
  config,
  lib,
  pkgs,
  globals,
  ...
}:

let
  inherit (globals) NIXOS_PRESETS;

  openwebui_port = 8902;
in
{
  containers.open-webui = {
    autoStart = true;
    bindMounts."/etc/ssl/certs".isReadOnly = true;
    bindMounts."/var/lib/private/open-webui" = {
      hostPath = "/data/open-webui";
      isReadOnly = false;
    };

    config =
      {
        config,
        lib,
        ...
      }:
      {
        imports = [
          "${NIXOS_PRESETS}/misc/nix-daemon.nix"
          "${NIXOS_PRESETS}/packages/core"
        ];

        nixpkgs.pkgs = pkgs;

        services.open-webui = {
          enable = true;
          host = "0.0.0.0";
          port = openwebui_port;
        };

        #services.nginx = {
        #  enable = true;
        #  virtualHosts."openwebui" = {
        #    default = true;
        #    forceSSL = true;
        #    sslCertificate = "/etc/ssl/certs/selfsigned.crt";
        #    sslCertificateKey = "/etc/ssl/certs/selfsigned.key";
        #    locations."/" = {
        #      proxyPass = "http://localhost:${toString openwebui_port}";
        #      proxyWebsockets = true;

        #      extraConfig = ''
        #        client_max_body_size 16G;
        #      '';
        #    };
        #  };
        #};

        networking = {
          hostName = "openwebui";
        };

        system.stateVersion = "24.11";
      };
  };

  # Override the container's systemd service to add the network-online.target dependency
  systemd.services."container@open-webui" = {
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
  };
}

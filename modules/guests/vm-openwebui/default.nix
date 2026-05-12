{
  inputs,
  lib,
  globals,
  ...
} @args:

let
  inherit (args.config) flake;
  inherit (globals) FLAKE_ROOT;

  hostName = "vm-openwebui";
  dataDir = "/data/open-webui";
  internal_port = 8901;
in
{
  flake.modules.nixos.${hostName} = flake.lib.mkMicroVM
    rec {
      enable = true;
      inherit hostName;
      system = "x86_64-linux";
      extraModules = [
        ### aspects
        ### 3rd party modules
        inputs.agenix.nixosModules.default
      ];
      microvmConfig = {
        networking = {
          macAddress = "02:00:00:00:00:09";
          ipAddress = "10.0.0.19";
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
      secrets = config.by.git-secrets;
    in
    {
      microvm.vcpu = 2;
      microvm.mem = 1024 * 8 + 1;
      microvm.shares = [
        {
          source = "/etc/ssl/certs";
          mountPoint = "/etc/ssl/certs";
          tag = "host-certs";
          proto = "virtiofs";
          socket = "openwebui-certs.sock";
        }
        {
          source = dataDir;
          mountPoint = "/var/lib/open-webui";
          tag = "openwebui-data";
          proto = "virtiofs";
          socket = "openwebui-data.sock";
        }
      ];
      microvm.writableStoreOverlay = "/nix/.rw-store";

      nix.nixPath = ["nixpkgs=${inputs.nixpkgs}"];
      nix.channel.enable = false;

      services.open-webui = {
        enable = true;
        host = "0.0.0.0";
        port = internal_port;
      };

      systemd.services.open-webui.serviceConfig = {
        DynamicUser = lib.mkForce false;
        User = "open-webui";
      };

      users.users.open-webui = {
        isSystemUser = true;
        group = "open-webui";
        extraGroups = [ "data" ];
      };
      users.groups.open-webui = {};

      services.nginx =
        let
          address = "vm-openwebui.${secrets.tailscale.magic_dns}";
        in
        {
          enable = true;
          recommendedGzipSettings = true;
          recommendedOptimisation = true;
          recommendedProxySettings = true;
          recommendedTlsSettings = true;
          virtualHosts."${address}" = {
            default = true;
            forceSSL = true;
            sslCertificate = "/etc/ssl/certs/${address}.crt";
            sslCertificateKey = "/etc/ssl/certs/${address}.key";
            locations."/" = {
              proxyPass = "http://localhost:${toString internal_port}";
              proxyWebsockets = true;

              extraConfig = ''
                client_max_body_size 16G;
              '';
            };
          };
        };
      # give access to certs
      users.users.nginx.extraGroups = [ "data" ];

      networking.firewall.allowedTCPPorts = [
        22
        80
        443
      ];
    });
}

{
  config,
  pkgs,
  globals,
  ...
}: 

let
  inherit (globals) FLAKE_ROOT;

  data = "/data/home-assistant";
  ha_port = 8123;
in
{
  age.secrets.cloudflare-key.file = "${FLAKE_ROOT}/secrets/piberry/cloudflare-key.age";

  services.home-assistant = {
    enable = true;
    customComponents = with pkgs.home-assistant-custom-components; [
      adaptive_lighting
    ];
    extraComponents = [
      # "analytics"
      "google_translate"
      "met"
      "radio_browser"
      "shopping_list"
      # recommended for fast zlib compression
      "isal"
    ];
    configDir = data;
    # manage imperatively
    config = null; 
    lovelaceConfig = null;
  };

  # Configure reverse proxy.
  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    virtualHosts =
      let
        tailscale = secrets.hosts.piberry.ssh.hostname;
      in
      {
        "${secrets.home-assistant.subdomain}" = {
          forceSSL = true;
          enableACME = true;
          # Disable ACME challenge generation to force DNS-01.
          acmeRoot = null;
          extraConfig = ''
            proxy_buffering off;
          '';
          locations."/" = {
            proxyPass = "http://[::1]:${ha_port}";
            proxyWebsockets = true;
          };
        };
        # tailscale address
        "${tailscale}" = {
          forceSSL = true;
          sslCertificate = "/etc/ssl/certs/${tailscale}.crt";
          sslCertificateKey = "/etc/ssl/certs/${tailscale}.key";
          extraConfig = ''
            proxy_buffering off;
          '';
          locations."/" = {
            proxyPass = "http://[::1]:${ha_port}";
            proxyWebsockets = true;
          };
        };
      };
    };

    security.acme = {
      acceptTerms = true;
      defaults.email = secrets.home-assistant.acme.email;
      certs = {
        "${secrets.home-assistant.subdomain}" = {
          domain = "*.${secrets.home-assistant.domain}";
          group = "nginx";
          dnsProvider = "cloudflare";
        # location of your CLOUDFLARE_DNS_API_TOKEN=[value]
        environmentFile = config.age.secrets.cloudflare-key.path;
      };
    };
  };
}

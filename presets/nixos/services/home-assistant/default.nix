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

  secrets = config.by.secrets;
in
{
  age.secrets.cloudflare-key.file = "${FLAKE_ROOT}/secrets/piberry/cloudflare-key.age";

  systemd.tmpfiles.rules = [
    "Z /data 770 piberry data"
    "Z /data/home-assistant 770 piberry data"
  ];

  users.groups.data = {};
  users.users.hass.extraGroups = [ "data" ];

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
      "matter"
      "bluetooth"
      "thread"
    ];
    extraPackages =  python3Packages: with python3Packages; [
      aiogithubapi
      aiohue
      elgato
      ha-ffmpeg
      hassil
      home-assistant-intents
      mutagen
      openrgb-python
      pymicro-vad
      pynacl
      pyspeex-noise
      python-matter-server
      pyturbojpeg
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
          # Specify which cert to use
          useACMEHost = "${secrets.home-assistant.domain}";
          # Disable ACME challenge generation to force DNS-01.
          acmeRoot = null;
          extraConfig = ''
            proxy_buffering off;
          '';
          locations."/" = {
            proxyPass = "http://[::1]:${toString ha_port}";
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
            proxyPass = "http://[::1]:${toString ha_port}";
            proxyWebsockets = true;
          };
        };
      };
    };

    security.acme = {
      acceptTerms = true;
      defaults.email = secrets.home-assistant.acme.email;
      certs = {
        "${secrets.home-assistant.domain}" = {
          domain = "${secrets.home-assistant.domain}";
          extraDomainNames = [ "*.${secrets.home-assistant.domain}" ];
          group = "nginx";
          dnsProvider = "cloudflare";
        # location of your CLOUDFLARE_DNS_API_TOKEN=[value]
        environmentFile = config.age.secrets.cloudflare-key.path;
      };
    };
  };
}

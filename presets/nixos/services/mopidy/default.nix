{
  config,
  pkgs,
  globals,
  ...
}:

let
  inherit (globals) FLAKE_ROOT;
  dataDir = "/data/mopidy";
  
  secrets = config.by.secrets.hosts;

  internal_port = 6680;
in
{
  systemd.tmpfiles.rules = [
    "d ${dataDir} 770 tauberry data -"
    "Z /etc/ssl/certs 750 root data -"
  ];

  age.secrets.mopidy-conf = {
    file = "${FLAKE_ROOT}/secrets/tauberry/mopidy-conf.age";
    owner = "mopidy";
  };

  services.mopidy = {
    enable = true;
    inherit dataDir;
    extensionPackages = with pkgs; [
      mopidy-muse
      mopidy-mopify
      mopidy-jellyfin
    ];
    settings = {
      core = {
        cache_dir = "${dataDir}/cache";
        config_dir = "${dataDir}/config";
      };
      http = {
        enabled = true;
        hostname = "127.0.0.1";
        port = internal_port;
        allowed_origins = secrets.tauberry.ssh.hostname;
      };
    };
    extraConfigFiles = [ config.age.secrets.mopidy-conf.path ];
  };

  services.nginx = 
  let
    address = secrets.tauberry.ssh.hostname;
  in
  {
    enable = true;
    #recommendedGzipSettings = true;
    #recommendedOptimisation = true;
    #recommendedProxySettings = true;
    #recommendedTlsSettings = true;
    virtualHosts."${address}" = {
      default = true;
      forceSSL = true;
      sslCertificate = "/etc/ssl/certs/${address}.crt";
      sslCertificateKey = "/etc/ssl/certs/${address}.key";
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString internal_port}";
        proxyWebsockets = true;

        extraConfig = ''
          client_max_body_size 16G;
        '';
      };
    };
  };

  users.users.mopidy.extraGroups = [ "keys" "data" ];
  users.users.nginx.extraGroups = [ "data" ];

  networking.firewall.allowedTCPPorts = [ 80 443 ];
}

{
  config,
  pkgs,
  lib,
  globals,
  ...
}:
with lib;

let
  secrets = config.by.secrets.weirdfish;
  inherit (globals) FLAKE_ROOT;

  cfg = config.by.websites;
in
{
  options.by.websites = {
    enable = mkEnableOption "dcurgz's websites module.";
    debug = mkOption {
      type = types.bool;
      description = "Enable nginx debug.";
      default = false;
    };
    sites = mkOption {
      type = with types; attrsOf (submodule ({ config, name, ... }: {
        options = {
          domain = mkOption {
            type = types.str;
            description = "The domain of the website to configure.";
          };
          acme.enable = mkEnableOption "Enable ACME automatic SSL certificate generation.";
          cloudflare.enable = mkEnableOption "Enable Cloudflare X-Real-IP configuration.";
          anubis = {
            enable = mkEnableOption "Enable Anubis, a filter-proxy, for this website.";
            ports.bind = mkOption {
              type = types.int;
              description = "The tcp port for Anubis to bind on.";
            };
            ports.target = mkOption {
              type = types.int;
              description = "The tcp port for Anubis to target.";
            };
            instanceOptions = mkOption {
              type = types.attrs;
              default = {
                DIFFICULTY = 4;
              };
              description = ''
                An attribute set of options to pass to Anubis instance-specific config.

                See https://github.com/NixOS/nixpkgs/blob/nixos-unstable/nixos/modules/services/networking/anubis.nix#L109
              '';
            };
            botPolicy = mkOption {
              type = types.attrs;
              default = {
                bots = [
                  # based on https://github.com/TecharoHQ/anubis/blob/3c76724/docs/manifest/cfg/anubis/botPolicies.yaml

                  { import = "(data)/crawlers/commoncrawl.yaml"; }
                  # Pathological bots to deny
                  # https://github.com/TecharoHQ/anubis/blob/main/data/bots/deny-pathological.yaml
                  { import = "(data)/bots/_deny-pathological.yaml"; }
                  { import = "(data)/bots/aggressive-brazilian-scrapers.yaml"; }

                  # Aggressively block AI/LLM related bots/agents by default
                  { import = "(data)/meta/ai-block-aggressive.yaml"; }

                  # Search engine crawlers to allow
                  { import = "(data)/crawlers/_allow-good.yaml"; }

                  # Challenge Firefox AI previews
                  { import = "(data)/clients/x-firefox-ai.yaml"; }

                  # Allow common "keeping the internet working" routes (well-known, favicon, robots.txt)
                  { import = "(data)/common/keep-internet-working.yaml"; }

                  # Allow RSS feeds
                  {
                    name = "rss-feed";
                    path_regex = "^/rss.xml$";
                    action = "ALLOW";
                  }

                  # Challenge everything claiming to be a browser
                  {
                    name = "generic-browser";
                    user_agent_regex = "Mozilla/";
                    action = "CHALLENGE";
                  }
                ];
              };
              description = ''
                A JSON object, defined in Nix langauge, to pass as the Anubis policy file.
              '';
            };
          };
          web-server = {
            enable = mkEnableOption "Enable a static web-server (nginx) to serve content post-filtering.";
            webroot = mkOption {
              type = types.str;
              description = "The path to the webroot for this website.";
            };
          };
        };
      }));
      default = {};
      description = "The websites that will be configured on this host.";
    };
  };

  config = mkIf (cfg.enable) {
    security.acme = {
      email = secrets.acme.email;
      acceptTerms = true;
    };

    services = {
      nginx = {
        enable = true;
        recommendedGzipSettings = true;
        recommendedOptimisation = true;
        recommendedProxySettings = true;
        recommendedTlsSettings = true;

        package = mkIf (cfg.debug) (with pkgs; nginx.override (_prev: { withDebug = true; }));
        logError = mkIf (cfg.debug) "/var/log/nginx/error.log debug";

        virtualHosts = mkMerge (mapAttrsToList (_sitename: site: {
          "${site.domain}" =
            if (site.anubis.enable) then
            {
              serverName = site.domain;
              forceSSL = true;
              enableACME = site.acme.enable;
              locations."/" = {
                proxyPass = "http://[::1]:${toString site.anubis.ports.bind}";
                extraConfig = mkIf (site.cloudflare.enable) ''
                  # https://www.cloudflare.com/en-gb/ips/
                  set_real_ip_from 173.245.48.0/20;
                  set_real_ip_from 103.21.244.0/22;
                  set_real_ip_from 103.22.200.0/22;
                  set_real_ip_from 103.31.4.0/22;
                  set_real_ip_from 141.101.64.0/18;
                  set_real_ip_from 108.162.192.0/18;
                  set_real_ip_from 190.93.240.0/20;
                  set_real_ip_from 188.114.96.0/20;
                  set_real_ip_from 197.234.240.0/22;
                  set_real_ip_from 198.41.128.0/17;
                  set_real_ip_from 162.158.0.0/15;
                  set_real_ip_from 104.16.0.0/13;
                  set_real_ip_from 104.24.0.0/14;
                  set_real_ip_from 172.64.0.0/13;
                  set_real_ip_from 131.0.72.0/22;
                  set_real_ip_from 2400:cb00::/32;
                  set_real_ip_from 2606:4700::/32;
                  set_real_ip_from 2803:f800::/32;
                  set_real_ip_from 2405:b500::/32;
                  set_real_ip_from 2405:8100::/32;
                  set_real_ip_from 2a06:98c0::/29;
                  set_real_ip_from 2c0f:f248::/32;
                  # https://github.com/TecharoHQ/anubis/pull/1034/commits/4c186c3ca6e6f1dd2088a8cf14d84fe568163c77
                  real_ip_header CF-Connecting-IP;
                  proxy_set_header X-Forwarded-For "";
                '';
                };
            }
            else
            {
              serverName = site.domain;
              forceSSL = true;
              enableACME = site.acme.enable;
              locations."/" = {
                index = "index.html";
                root = site.web-server.webroot;
              };
            };
          "${site.domain}-post-filter" = mkIf (site.anubis.enable && site.web-server.enable) {
            listen = [
              {
                addr = "[::1]";
                port = site.anubis.ports.target;
              }
            ];
            serverName = site.domain;
            root = site.web-server.webroot;
          };
        }) cfg.sites);
      };

      anubis.instances = mkMerge (mapAttrsToList (_sitename: site: {
        "${site.domain}" = mkIf (site.anubis.enable) {
          enable = true;
          settings = {
            TARGET = "http://[::1]:${toString site.anubis.ports.target}";
            BIND = ":${toString site.anubis.ports.bind}";
            BIND_NETWORK = "tcp";
            METRICS_BIND = "/run/anubis/anubis-${site.domain}/anubis-metrics.sock";
          } // site.anubis.instanceOptions;
          botPolicy = site.anubis.botPolicy;
        };
      }) cfg.sites);
    };

    networking.firewall.allowedTCPPorts = [ 80 443 ];
  };
}

{
  self,
  inputs,
  config,
  pkgs,
  lib,
  globals,
  ...
}:
let
  secrets = config.by.secrets.weirdfish;
  ports   = config.by.portmap;
  inherit (globals) FLAKE_ROOT;

  domain = "dcurgz.me";

  inherit (config.by.www."${domain}") webroot;
in
{
  config.by.websites.enable = true;
  config.by.websites.debug = true;
  config.by.websites.sites.${domain} = {
    domain = domain;
    acme.enable = true;
    cloudflare.enable = true;
    anubis = {
      enable = true;
      ports = {
        bind = ports.internal.anubis + 1;
        target = ports.internal.nginx + 1;
      };
    };
    web-server = {
      enable = true;
      webroot = "${webroot}";
    };
  };
}

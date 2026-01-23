{
  self,
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

  domain = "weirdfi.sh";
in
{
  by.websites.enable = true;
  by.websites.sites.${domain} = {
    domain = domain;
    acme.enable = true;
    cloudflare.enable = true;
    anubis = {
      enable = true;
      ports = {
        bind   = ports.internal.anubis;
        target = ports.internal.weirdfish;
      };
    };
  };
  weirdfish-server = {
    enable = true;
    listen = "[::]:${toString ports.internal.weirdfish}";
    webroot = toString config.by.www."${domain}".webroot;
    template_params = {
      git-rev = toString (self.shortRev or self.dirtyShortRev or self.lastModified or "unknown");
    };
  };
}

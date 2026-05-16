{
  inputs,
  ...
} @args:
let
  inherit (args.config) flake;
  inherit (args.globals) FLAKE_ROOT;
in

{
  flake.modules.nixos."dcurgz.me" = flake.lib.nixos.mkAspect []
    ({
      lib,
      config,
      ...
    }:

    let
      secrets = config.by.secrets.weirdfish;
      ports   = config.by.portmap;
    
      domain = "dcurgz.me";
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
          # webroot is defined under ./webroot
        };
      };
    });
}

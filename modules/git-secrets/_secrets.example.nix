{
  inputs,
  ...
} @args:

let
  inherit (args.config) flake;
in
{
  flake.modules.generic.git-secrets = flake.lib.generic.mkAspect (with flake.tags; [ flake-default ])
    ({
      lib,
      config,
      ...
    }:

    let
      magic_dns = "";
      mkTailnetHost = hostname: user: {
        ssh = {
          host = hostname;
          hostname = "${hostname}.${magic_dns}";   
          user = user;
        };
      };
      mkNormalHost = host: hostname: user: {
        ssh = {
          inherit host hostname user;
        };
      };
      mkGuest = hostname: {
        ssh = {
          host = hostname;
          hostname = "${hostname}.${magic_dns}";
          user = hostname;
        };
      };
    in
    {
      config.by.git-secrets = {
        wireguard."001" = {
          address = [ ];
          endpoint = "";
          publicKey = "";
        };
        tailscale = { inherit magic_dns; };
        hosts = {
          # hosts
          blueberry  = mkTailnetHost "blueberry"   "dcurgz";
          airberry   = mkTailnetHost "airberry"    "dylan";
          piberry    = mkTailnetHost "piberry"     "piberry";
          tauberry   = mkTailnetHost "tauberry"    "tauberry";
          fooberry   = mkTailnetHost "fooberry"    "fooberry";
          
          hyperberry = lib.mkMerge [
            (mkTailnetHost "hyperberry" "dcurgz")
            {
              ssh.builder.enable = true;
            }
          ];
          miniberry = lib.mkMerge [
            (mkTailnetHost "miniberry" "dcurgz") 
            {
              ssh.builder.enable = true;
            }
          ];

          weirdfish-cax11-4gb   = mkNormalHost "weirdfi.sh" "a.b.c.d" "dcurgz";
          publicproxy-cax11-4gb = mkNormalHost "publicproxy" "a.b.c.d" "dcurgz";

          # guests
          vm-jellyfin     = mkGuest "vm-jellyfin";
          vm-vikunja      = mkGuest "vm-vikunja";
          vm-immich       = mkGuest "vm-immich";
          vm-teamspeak    = mkGuest "vm-teamspeak";
          vm-openwebui    = mkGuest "vm-openwebui";
          vm-mc-slime-0   = mkGuest "vm-mc-slime-0";
          vm-mc-slime-1   = mkGuest "vm-mc-slime-1";
          vm-mc-wg-0      = mkGuest "vm-mc-wg-0";
          vm-mc-wg-1      = mkGuest "vm-mc-wg-1";
          vm-mc-leedlemon = mkGuest "vm-mc-leedlemon";
          vm-trilium      = mkGuest "vm-trilium";
        };
        home-assistant = {
          domain = "example.com";
          subdomain = "subdomain.example.com";
          acme.email = "acme+john.doe@exampl.com";
        };
        fooberry-proxy = {
          domain = "example.com";
          subdomain = "subdomain.example.com";
          acme.email = "acme+john.doe@example.com";
        };
        weirdfish-acme = {
          email = "acme+john.doe@example.com";
        };
      };
    });
}

{
  inputs,
  lib,
  ...
} @args:

let
  inherit (args.config) flake;
    magic_dns = "tail0ec3ec.ts.net";
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
    git-secrets = {
      wireguard."001" = {
        address = [
          "10.65.252.142/32"
          "fc00:bbbb:bbbb:bb01::2:fc8d/128"
        ];
        endpoint = "193.32.127.84:51820";
        publicKey = "wDjbvO94t0UI1RlimpEFFv7kJ6DngthvuRX6uBN0wAA=";
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

        weirdfish-cax11-4gb   = mkNormalHost "weirdfi.sh" "188.245.179.29" "dcurgz";
        publicproxy-cax11-4gb = mkNormalHost "publicproxy" "49.12.228.45" "dcurgz";

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
        domain = "commune.gay";
        subdomain = "home-assistant.commune.gay";
        acme.email = "joy.ginn@outlook.com";
      };
      fooberry-proxy = {
        domain = "curzon.club";
        subdomain = "jellyfin.curzon.club";
        acme.email = "a+acme+curzon.club@curz.sh";
      };
      weirdfish-acme = {
        email = "a+acme@curz.sh";
      };
    };

  mkModule = class: flake.lib.${class}.mkAspect (with flake.tags; [ flake-default ])
    (_args: {
      config.by.git-secrets = git-secrets;
    });
in
{
  flake.modules.generic.git-secrets = mkModule "generic";
  flake.modules.nixos.git-secrets = mkModule "nixos";
  flake.modules.darwin.git-secrets = mkModule "darwin";
  flake.modules.home-manager.git-secrets = mkModule "home-manager";
}

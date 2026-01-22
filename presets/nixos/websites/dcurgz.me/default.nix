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
  inherit (inputs) nix-time;
  inherit (globals) FLAKE_ROOT;

  domain = "dcurgz.me";

  inherit (pkgs) stdenv;
  site-index = stdenv.mkDerivation {
    name = "site-index";
    src = "${FLAKE_ROOT}/www/${domain}";
    nativeBuildInputs = with pkgs; [ mandoc ];
    buildPhase = ''
      mandoc -T html -O style=style.css index.7 > index.html
    '';
    installPhase = ''
      cp ./index.html "$out"
    '';
  };
  site-webroot = (pkgs.linkFarm "site-webroot" [
    {
      name = "index.html";
      path = (pkgs.replaceVars site-index {
        nix-gitrev = toString (self.shortRev or self.dirtyShortRev or self.lastModified or "unknown");
        nix-date = nix-time.lib.ISO-8601 self.lastModified;
      });
    }
    {
      name = "style.css";
      path = "${FLAKE_ROOT}/www/${domain}/style.css";
    }
  ]);
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
      webroot = "${site-webroot}";
    };
  };
}

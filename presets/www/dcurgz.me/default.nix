{
  self,
  inputs,
  pkgs,
  globals,
  ...
}:

let
  inherit (globals) FLAKE_ROOT;
  inherit (pkgs) stdenv;
  inherit (inputs) nix-time;
  index = stdenv.mkDerivation {
    name = "index";
    src = ./.;
    nativeBuildInputs = with pkgs; [ mandoc ];
    buildPhase = ''
      mandoc -T html -O style=style.css index.7 > index.html
    '';
    installPhase = ''
      cp ./index.html "$out"
    '';
  };
  webroot = (pkgs.linkFarm "webroot" [
    {
      name = "index.html";
      path = (pkgs.replaceVars index {
        nix-gitrev =
          toString (self.shortRev or self.dirtyShortRev or self.lastModified or "unknown");
        nix-rfc822 = nix-time.lib.RFC-822 "GMT" self.lastModified;
        nix-date =
          with nix-time.lib.splitSecondsSinceEpoch {} self.lastModified;
          let
            month = toString B;
            day   = toString d;
            year  = toString Y;
          in
            "${month} ${day}, ${year}";
      });
    }
    {
      name = "style.css";
      path = ./style.css;
    }
    {
      name = "rss.xml";
      path = (pkgs.replaceVars ./rss.xml {
        nix-rfc822 = nix-time.lib.RFC-822 "GMT" self.lastModified;
      });
    }]);
in
{
  config.by.www."dcurgz.me".webroot = webroot;
}

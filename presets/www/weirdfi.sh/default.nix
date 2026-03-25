{
  self,
  pkgs,
  lib,
  inputs,
  globals,
  ...
}:

let
  inherit (globals) FLAKE_ROOT;
  inherit (pkgs) stdenv;
  inherit (inputs) nix-time;
  posts = stdenv.mkDerivation {
    name = "weirdfish-posts";
    src = ./.;
    nativeBuildInputs = with pkgs; [ mandoc ];
    buildPhase = ''
      FILES=$(find . -name "*.7")
      for f in $FILES; do
        DEST="''${f%.7}.html"
        mandoc -T html -O style="/style.css" $f > $DEST
      done
    '';
    installPhase = ''
      mkdir -p "$out"
      FILES=$(find . -name "*.html")
      for f in $FILES; do
        DIR=$(dirname "$f")
        mkdir -p $out/"$DIR"
        cp "$f" $out/"$f"
      done
    '';
  };
  inherit (pkgs.by.lib) replaceOptionalVars;
  mkTemplate = name: path: {
    inherit name;
    path = (replaceOptionalVars path {
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
  };
  index = builtins.toFile "index.html" (import ./index.nix { inherit self lib inputs; });
  webroot = (pkgs.linkFarm "webroot" [
    #(mkTemplate "index.html" index)
    {
      name = "index.html";
      path = index;
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
  config.by.www."weirdfi.sh".webroot = webroot;
}

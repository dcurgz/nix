{
  self,
  inputs,
  lib,
  pkgs,
  globals,
  ...
}:

let
  inherit (globals) FLAKE_ROOT;
  inherit (pkgs) stdenv;
  inherit (inputs) nix-time;

  inherit (pkgs.by.lib) replaceOptionalVars;

  renderMdoc = path: lib.pipe path [
    (path: stdenv.mkDerivation (
      let
        name  = builtins.baseNameOf path;
        name' = lib.replaceString ".7" ".html" name;
      in
      {
        inherit name;
        nativeBuildInputs = with pkgs; [ mandoc ];
        src = builtins.dirOf path;
        buildPhase = ''
          mandoc -T html -O style=/style.css "$src/${name}" > ${name'}
        '';
        installPhase = ''
          cp ./${name'} "$out"
        '';
      }))
    (path: replaceOptionalVars path {
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
      color-scheme = builtins.readFile ./color-scheme.html;
    })
  ];

  webroot = (pkgs.linkFarm "webroot" [
    {
      name = "index.html";
      path = renderMdoc ./index.7;
    }
    {
      name = "posts/index.html";
      path = renderMdoc ./posts/index.7;
    }
    {
      name = "posts/001_NixOS.html";
      path = renderMdoc ./posts/001_NixOS.7;
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

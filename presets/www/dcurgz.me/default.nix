{
  self,
  inputs,
  lib,
  config,
  pkgs,
  globals,
  ...
}:

let
  inherit (globals) FLAKE_ROOT;
  inherit (pkgs) stdenv;
  inherit (inputs) nix-time;

  inherit (pkgs.by.lib) replaceOptionalVars;
in
{
  imports = [
    ./pages/index
    ./pages/posts/001-NixOS
  ];

  options.config.by.www."dcurgz.me".pages = lib.mkOption {
    type = lib.types.listOf (lib.types.submodule {
      options = {
        title = lib.types.str;
        slug = lib.types.str;
        src = lib.types.derivation;
      };
    });
  };

  config.by.www."dcurgz.me".webroot =
    let
      cfg = config.by.www."dcurgz.me";
      files = builtins.map (page: {
        name = page.slug;
        path = page.src;
      }) cfg.pages;
      resources = [
        {
          name = "style.css";
          path = (stdenv.mkDerivation {
            name = "compiled-styles";
            src = ./.;
            buildPhase = ''
              cat *.css > ./output.css
            '';
            installPhase = ''
              cp ./output.css $out
            '';
          });
        }
        {
          name = "rss.xml";
          path = (pkgs.replaceVars ./rss.xml {
            nix-rfc822 = nix-time.lib.RFC-822 "GMT" self.lastModified;
          });
        }
      ];
    in
    pkgs.linkFarm "webroot" (files ++ resources);
}

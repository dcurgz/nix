{
  inputs,
  ...
} @args:
let
  inherit (args.config) flake;
  inherit (args.globals) FLAKE_ROOT;
in

{
  # Install to flake-default; dcurgz.me is enabled based on the uppermost module.
  flake.modules.nixos."dcurgz.me-webroot" = flake.lib.nixos.mkAspect (with flake.tags; [ flake-default ])
    ({
      lib,
      config,
      pkgs,
      ...
    }:

    let
      inherit (pkgs) stdenv;
      inherit (inputs) nix-time;
    
      inherit (pkgs.by.lib) replaceOptionalVars;

      domain = "dcurgz.me";
    in
    {
      options.by.www.${domain} = {
        pages = lib.mkOption {
          type = lib.types.listOf (lib.types.submodule {
            options = {
              title       = lib.mkOption { type = lib.types.str; };
              description = lib.mkOption { type = lib.types.str; };
              date        = lib.mkOption { type = lib.types.str; };
              slug        = lib.mkOption { type = lib.types.str; };
              src         = lib.mkOption { type = lib.types.package; };
            };
          });
        };
        templates = lib.mkOption {
          type = lib.types.attrsOf lib.types.str;
        };
        lib = lib.mkOption {
          type = lib.types.attrsOf lib.types.anything;
        };
      };
    
      config.by.websites.sites.${domain}.web-server.webroot =
        let
          cfg = config.by.www.${domain};
          files = builtins.map (page: {
            name = page.slug;
            path = page.src;
          }) cfg.pages;
          resources = [
            {
              name = "style.css";
              path = (stdenv.mkDerivation {
                name = "compiled-styles";
                src = ./stylesheets;
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
                nix-rfc822 = nix-time.lib.RFC-822 "GMT" inputs.self.lastModified;
              });
            }
          ];
        in
        pkgs.linkFarm "webroot" (files ++ resources);
    });
}


{
  inputs,
  ...
} @args:
let
  inherit (args.config) flake;
in

{
  flake.modules.nixos."dcurgz.me-index" = flake.lib.nixos.mkAspect (with flake.tags; [ flake-default ])
    ({
      lib,
      config,
      pkgs,
      ...
    }:

    let
      inherit (pkgs.by.lib) replaceOptionalVars;
      cfg = config.by.www."dcurgz.me";
      inherit (cfg) templates;
      lib' = cfg.lib;
    in
    {
      config.by.www."dcurgz.me".pages = [
        {
          title = "DCURGZ.ME";
          description = "Site Index";
          date = "2026-05-12";
          slug = "index.html";
          src = lib.pipe ./index.7 [
            (path: replaceOptionalVars path templates)
            (path: lib'.renderMdoc "index.html" path)
          ];
        }
      ];
    });
}

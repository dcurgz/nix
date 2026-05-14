{
  inputs,
  ...
} @args:
let
  inherit (args.config) flake;
in

{
  flake.modules.nixos."dcurgz.me-001-NixOS" = flake.lib.nixos.mkAspect (with flake.tags; [ flake-default ])
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

      children = [
        rec {
          title = "001.a Declarative Secrets";
          description = "A two-tiered approach to secrets management with Nix";
          date = "2026-05-14";
          slug = "posts/NixOS/001.a-declarative-secrets.html";
          src = lib.pipe ./declarative-secrets.7 [
            (path: replaceOptionalVars path { inherit title description; })
            (path: replaceOptionalVars path templates)
            (path: lib'.renderMdoc "declarative-secrets.html" path)
          ];
        }
      ];
    in
    {
      config.by.www."dcurgz.me".pages = [
        rec {
          title = "001 Nix and NixOS (series)";
          description = "A collection of posts about Nix";
          date = "2026-05-14";
          slug = "posts/NixOS/index.html";
          src = lib.pipe ./index.7 [
            (path: replaceOptionalVars path {
              inherit title description;
              series =
                let
                  posts = lib.pipe children [
                    # render as mdoc list
                    (builtins.map (post: ''
                      .It
                      .Lk ${post.slug} ${post.title} 
                      — ${post.description}
                      .Em (${post.date})
                    ''))
                    # join list to string
                    (lib.strings.join "\n")
                  ];
                in
                ''
                  .Bl
                  ${posts}
                  .El
                '';
            })
            (path: replaceOptionalVars path templates)
            (path: lib'.renderMdoc "index.html" path)
          ];
        }
      ];
    });
}

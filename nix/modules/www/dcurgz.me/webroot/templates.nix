{
  inputs,
  ...
} @args:
let
  inherit (args.config) flake;
in

{
  flake.modules.nixos."dcurgz.me-templates" = flake.lib.nixos.mkAspect (with flake.tags; [ flake-default ])
    ({
      lib,
      config,
      pkgs,
      ...
    }:

    let
      cfg = config.by.www."dcurgz.me";
      lib' = cfg.lib;
    in
    {
      config.by.www."dcurgz.me".templates = {
        back = ''
          .Lk / "↩ take me home"
        '';
        build-time = ''
          .Pp
          This site was built
          .Lk https://github.com/dcurgz/nix/blob/master/presets/www/dcurgz.me/default.nix declaratively
          on __HTML<code-inline>@nix-rfc822@</code-inline>__ENDHTML.
        '';
        contact =
          let
            contact-script = ''
              #!/usr/bin/env bash
              echo "E: zr@phem.fu" | tr "[n-za-m]" "[a-z]"
            '';
            contact-script' = lib'.renderCode {
              name = "contact-script-rendered";
              lang = "bash";
              path = pkgs.writeText "contact-script" contact-script;
            };
          in ''
            .Bd -literal -offset indent -compact
            __HTML${contact-script'}__ENDHTML
            .Ed
          '';
        header = ''
          .Dd @color-scheme@
          .Dt DCURGZ.ME 7
          .Os @nix-gitrev@
        '';
        recent-posts =
          let
            posts = lib.pipe cfg.pages [
              # only show posts
              (builtins.filter (post: pkgs.by.lib.strings.startsWith "posts/" post.slug))
              # sort by date
              (builtins.sort (a: b: a < b))
              # take the last 10 posts (assume chronological order)
              (lib.lists.takeEnd 10)
              # render as mdoc list
              (builtins.map (post: ''
                .It
                .Lk ${post.slug} ${post.title} 
                — ${post.description}
                .Em (${post.date})
              ''))
              # 
              (lib.strings.join "\n")
            ];
          in ''
          .Bl
          ${posts}
          .El
        '';
      };
    });
}

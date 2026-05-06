{
  inputs,
  ...
} @args:
let
  inherit (args.config) flake;
in

{
  flake.modules.nixos.linux-groups = flake.lib.nixos.mkAspect []
    ({
      lib,
      config,
      ...
    }:

    let
      mkGroup = gid: {
        inherit gid;
      };
    in
    {
      # The intention is to make groups across all hosts and guests well
      # defined, so that gids in shared filesystems mean the same thing
      # universally.
      users.groups = {
        media = mkGroup 3001;
        data  = mkGroup 3002;
      };
    });
}

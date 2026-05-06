{
  inputs,
  ...
} @args:
let
  inherit (args.config) flake;
  inherit (args.config.by) keys;
in

{
  flake.modules.nixos.authorized-keys = flake.lib.nixos.mkAspect []
    ({
      lib,
      config,
      ...
    }:

    let
      cfg = config.by.presets.authorized-keys;
    in
    {
      options.by.presets.authorized-keys = {
        groups = lib.mkOption {
          type = lib.types.listOf (lib.types.submodule {
            options = {
              users = lib.mkOption {
                type = lib.types.listOf lib.types.str;
                default = [ ];
              };
              keys = lib.mkOption {
                type = lib.types.listOf lib.types.path;
                default = [ ];
              };
            };
          });
        };
      };

      config.users.users =
        lib.mkMerge (builtins.map (group:
          lib.mkMerge (builtins.map (user:
            {
              ${user}.openssh.authorizedKeys.keyFiles = group.keys;
            }
          ) group.users)
        ) cfg.groups);
    });
}

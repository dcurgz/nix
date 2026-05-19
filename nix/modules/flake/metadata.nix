{
  inputs,
  lib,
  config,
  ...
}:

{
  options.flake.metadata = lib.mkOption {
    type = lib.types.attrsOf (lib.types.submodule {
      options = {
        type        = lib.mkOption { type = lib.types.enum (builtins.attrValues config.flake.things); };
        description = lib.mkOption { type = lib.types.str; };
        parent      = lib.mkOption { type = lib.types.nullOr lib.types.attrs; };
        attributes  = {
          uplinks = lib.mkOption {
            type = lib.types.nullOr (lib.types.attrsOf (lib.types.submodule {
              options = {
                ipAddress = lib.mkOption { type = lib.types.nullOr lib.types.str; };
                managed = lib.mkOption { type = lib.types.bool; default = false; };
              };
            }));
          };
          services = lib.mkOption {
            type = lib.types.nullOr (lib.types.attrsOf (lib.types.submodule {
              options = {
                description = lib.mkOption { type = lib.types.nullOr lib.types.str; };
              };
            }));
          };
        };
      };
    });
    default = { };
    description = ''
      An attrset of metadata pertaining to flake-parts modules.

      For example, `flake.modules.nixos.blueberry` might be described by its
      corresponding metadata at `flake.metadata.blueberry`.
    '';
  };

  # A list of well-defined things to describe modules.
  config.flake.things = {
    host  = "host";
    guest = "guest";
    vps   = "vps";
  };
}

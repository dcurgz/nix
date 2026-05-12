{
  inputs,
  ...
} @args:
let
  inherit (args.config) flake;
in

{
  flake.modules.nixos.linux-portmap = flake.lib.nixos.mkAspect (with flake.tags; [ nixos-base ])
    ({
      lib,
      config,
      ...
    }:

    {
      options.by.portmap = lib.mkOption {
        type = lib.types.attrsOf lib.types.anything;
      };

      config.by.portmap = {
        internal = 
          let 
            __base = 8090;
          in
          {
            # Note, leave gaps to allow for multiple instances.
            anubis = __base + 1;
            nginx  = __base + 5;
            weirdfish = __base + 9;
          };
      };
    });
}

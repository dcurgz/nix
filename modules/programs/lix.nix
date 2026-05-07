{
  inputs,
  ...
} @args:
let
  inherit (args.config) flake;
in

{
  flake.modules.nixos.lix = flake.lib.nixos.mkAspect []
    ({
      lib,
      config,
      pkgs,
      ...
    }:

    {
      nix.package = pkgs.lixPackageSets.stable.lix;
    });

  flake.modules.darwin.lix = flake.lib.darwin.mkAspect []
    ({
      lib,
      config,
      pkgs,
      ...
    }:

    {
      nix.package = pkgs.lixPackageSets.stable.lix;
    });
}

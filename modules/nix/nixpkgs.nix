{
  inputs,
  globals,
  ...
}:

let
  inherit (globals) FLAKE_ROOT;

  base = {
    nixpkgs.overlays = [
      (final: prev: import "${FLAKE_ROOT}/pkgs" { inherit inputs final prev; })
    ];
    nixpkgs.config.allowUnfree = true;
  };
in
{
  flake.modules.nixos.nixpkgs =
    {
      lib,
      config,
      ...
    }: base;

  flake.modules.darwin.nixpkgs =
    {
      lib,
      config,
      ...
    }: base;
}

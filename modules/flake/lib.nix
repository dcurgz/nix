{
  inputs,
  lib,
  globals,
  ...
}:

let
  inherit (globals) FLAKE_ROOT;
in
{
  config.flake.lib = {
    mkNixOS = args: inputs.nixpkgs.lib.nixosSystem args;
    mkDarwin = args: inputs.nix-darwin.lib.darwinSystem args;
  }; 
}

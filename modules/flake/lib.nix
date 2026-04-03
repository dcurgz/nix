{
  self,
  inputs,
  config,
  lib,
  ...
}:

{
  config.flake.lib = {
    mkNixOS  = args: inputs.nixpkgs.lib.nixosSystem args;
    mkDarwin = args: inputs.nix-darwin.lib.darwinSystem args;
  }; 
}

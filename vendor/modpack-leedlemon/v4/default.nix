{
  pkgs,
  ...
}:

let
  modpack = pkgs.callPackage ./modpack.nix { };
in
  modpack

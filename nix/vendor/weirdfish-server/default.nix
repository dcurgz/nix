{
  pkgs ? import <nixpkgs>,
  naersk',
  ...
}:

naersk'.buildPackage ./.

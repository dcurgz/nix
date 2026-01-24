{
  pkgs,
  naersk',
  ...
}:
with pkgs;

let 
  dcurgz = callPackage ./dcurgz { inherit naersk'; };
  third-party = callPackage ./3rd-party { };
  lib = callPackage ./lib { };
in
  dcurgz // third-party // lib

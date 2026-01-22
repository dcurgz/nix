{
  pkgs,
  naersk',
  ...
}:
with pkgs;

let 
  dcurgz = callPackage ./dcurgz { inherit naersk'; };
  third-party = callPackage ./3rd-party { };
in
  dcurgz // third-party

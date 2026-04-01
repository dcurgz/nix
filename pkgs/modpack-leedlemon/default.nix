{
  lib,
  pkgs,
  ...
}:

{
  v1 = pkgs.callPackage ./v1 { };
  v2 = pkgs.callPackage ./v2 { };
  v3 = pkgs.callPackage ./v3 { };
  v4 = pkgs.callPackage ./v4 { };
  v5-staging = pkgs.callPackage ./v5-staging { };
}

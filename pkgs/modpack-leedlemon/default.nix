{
  pkgs,
  ...
}:

{
  v1 = pkgs.callPackage ./v1 { };
  v2 = pkgs.callPackage ./v2 { };
  v3 = pkgs.callPackage ./v3 { };
}

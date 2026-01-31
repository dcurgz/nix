{
  pkgs,
  ...
}:

{
  v2 = pkgs.callPackage ./v2 { };
  v3 = pkgs.callPackage ./v3 { };
  v4 = pkgs.callPackage ./v4 { };
}

{
  pkgs,
  ...
}:

{
  v1 = pkgs.callPackage ./v1 { };
  v2 = pkgs.callPackage ./v2 { };
}

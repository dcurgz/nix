{
  pkgs,
  ...
}:

{
  v1 = pkgs.callPackage ./v1 { };
}

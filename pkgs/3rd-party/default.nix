{
  pkgs,
  ...
}:

with pkgs;
{
  firefox-csshacks = callPackage ./firefox-csshacks { };
}

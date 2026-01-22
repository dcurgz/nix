{
  pkgs,
  ...
}:

with pkgs;
{
  firefox-csshacks = callPackage ./3rd-party/firefox-csshacks { };
}

{
  pkgs,
  naersk',
  ...
}:
with pkgs;

{
  firefox-csshacks = pkgs.callPackage ./firefox-csshacks { };
  flockenzeit = pkgs.callPackage ./flockenzeit { };
  weirdfish-server = pkgs.callPackage ./weirdfish-server { };
  keylight = pkgs.callPackage ./keylight { };
  # Minecraft
  neoforge-1-21-1 = pkgs.callPackage ./neoforge-1-21-1 { };
  # Modpacks
  modpack-slime = pkgs.callPackage ./modpack-slime { };
}

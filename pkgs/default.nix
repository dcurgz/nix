{
  pkgs,
  naersk',
  ...
}:
with pkgs;

{
  # External
  firefox-csshacks = pkgs.callPackage ./external/firefox-csshacks { };
  flockenzeit = pkgs.callPackage ./external/flockenzeit { };
  # Minecraft
  neoforge-1-21-1 = pkgs.callPackage ./neoforge-1-21-1 { };
  magma-1-21-1 = pkgs.callPackage ./magma-1-21-1 { };
  # Modpacks
  modpack-slime = pkgs.callPackage ./modpack-slime { };
  modpack-leedlemon = pkgs.callPackage ./modpack-leedlemon { };
  # My projects
  weirdfish-server = pkgs.callPackage ./weirdfish-server { };
  keylight = pkgs.callPackage ./keylight { };
}

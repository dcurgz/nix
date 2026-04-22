{
  inputs,
  prev,
  final,
}:

{
  firefox-csshacks = prev.callPackage ./firefox-csshacks { };
  flockenzeit = prev.callPackage ./flockenzeit { };
  weirdfish-server = prev.callPackage ./weirdfish-server { };
  keylight = prev.callPackage ./keylight { };
  # Minecraft
  neoforge-1-21-1 = prev.callPackage ./neoforge-1-21-1 { };
  # Modpacks
  modpack-slime = prev.callPackage ./modpack-slime { };
  modpack-leedlemon = prev.callPackage ./modpack-leedlemon { };
}

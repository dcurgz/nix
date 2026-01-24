{
  pkgs,
  naersk',
  ...
}:
with pkgs;

{
  neoforge-1-21-1 = callPackage ./minecraft/neoforge-server { };
  modpack-slime = callPackage ./minecraft/modpack-slime { };
  weirdfish-server = callPackage ./weirdfish-server { inherit naersk'; };
}

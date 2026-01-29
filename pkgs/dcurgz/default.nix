{
  pkgs,
  naersk',
  ...
}:
with pkgs;

{
  neoforge-1-21-1 = callPackage ./minecraft/neoforge-server { };
  weirdfish-server = callPackage ./weirdfish-server { inherit naersk'; };
  # Minecraft modpacks
  modpack-slime = callPackage ./minecraft/modpack-slime { };
  modpack-slime-v3 = callPackage ./minecraft/modpack-slime-v3 { };
}

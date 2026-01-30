{
  pkgs,
  ...
}:

let
  version = "3";
in
  {
    by.programs.prism-launcher = {
      enable = true;
      shareDirectory = {
        path = "/home/dcurgz/.local/share/PrismLauncher";
        user = "dcurgz";
        group = "dcurgz";
      };
      packs = {
        "slime-v${version}" = {
          instanceConfig = {
            name = "slime-v${version}";
            ManagedPackType = "modrinth";
            AutomaticJava = true;
            MaxMemAlloc = 1024*10;
            MinMemAlloc = 1024*4;
            OverrideMemory = true;
          };
          components = [
            rec {
              version = "3.3.3";
              cachedVersion = version;
              uid = "org.lwjgl3";
              dependencyOnly = true;
              cachedName = "LWJGL 3";
            }
            rec {
              version = "1.21.1";
              cachedVersion = version;
              uid = "net.minecraft";
              important = true;
              cachedName = "Minecraft";
            }
            rec {
              version = "21.1.218";
              cachedVersion = version;
              uid = "net.neoforged";
              important = true;
              cachedName = "NeoForge";
            }
          ];
          modpack = pkgs.local."modpack-slime-v${version}";
        };
      };
    };
  }

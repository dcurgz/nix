{
  inputs,
  globals,
  ...
} @args:

let
  inherit (globals) FLAKE_ROOT;

  vendor = "${FLAKE_ROOT}/vendor";
in
_final: prev: {
  external = {
    claude-code-acp =  prev.callPackage "${vendor}/claude-code-acp" { };
    firefox-csshacks = prev.callPackage "${vendor}/firefox-csshacks" { };
    flockenzeit =      prev.callPackage "${vendor}/flockenzeit" { };
    vmnet-helper =     prev.callPackage "${vendor}/vmnet/vmnet-helper" { };
    vmnet-broker =     prev.callPackage "${vendor}/vmnet/vmnet-broker" { };
  };

  by = prev.by // {
    # Minecraft
    magma-1-21-1 =      prev.callPackage "${vendor}/magma-1-21-1" { };
    # Modpacks
    modpack-leedlemon = prev.callPackage "${vendor}/modpack-leedlemon" { };
    modpack-slime =     prev.callPackage "${vendor}/modpack-slime" { };
    # My projects
    keylight =          prev.callPackage "${vendor}/keylight" { };
    mandoc-fork =       prev.callPackage "${vendor}/mandoc" { };
  
    # Inputs
    neoforge-1-21-1 =  inputs.neoforge-1-21-1.packages.${prev.system}.default;
    weirdfish-server = inputs.weirdfish-server.packages.${prev.system}.default;

    # Local bin scripts
    local-scripts = prev.stdenv.mkDerivation {
      name = "local-scripts";
      src = "${FLAKE_ROOT}/bin";
      installPhase = ''
        mkdir -p $out/bin
        find . -maxdepth 2 \( -type f -o -type l \) -executable \
          -exec cp -pL {} $out/bin \;
      '';
      meta = with prev.lib; {
        description = "Local utility scripts";
        platforms = platforms.all;
      };
    };
  };
}

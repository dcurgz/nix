{
  inputs,
  final,
  prev,
  ...
}:

let
  naersk' = prev.callPackage inputs.naersk { };
in
{
  # Import our custom package set
  by = import ./pkgs {
    pkgs = final;
    inherit prev naersk';
  } // {
    lib = prev.callPackage ./lib { };
  };
  # Import other input package sets
  #quickshell = inputs.quickshell.packages.${prev.system}.default;
  isd = inputs.isd.packages.${prev.system}.default;
  deploy-rs = inputs.deploy-rs.packages.${prev.system}.default or null;
  agenix = inputs.agenix.packages.${prev.system}.default;
  dankMaterialShell = inputs.dankMaterialShell.packages.${prev.system}.default;

  inherit (inputs.nfsm.packages.${prev.system}) nfsm nfsm-cli;

  # Local bin scripts
  local-scripts = prev.stdenv.mkDerivation {
    name = "local-scripts";
    src = ./bin;
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
}

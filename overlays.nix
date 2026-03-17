{
  inputs,
  final,
  prev,
  ...
}:

let
  naersk' = prev.callPackage inputs.naersk { };
in rec {
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
  niri = inputs.niri.packages.${prev.system}.niri-unstable;

  inherit (inputs.nfsm.packages.${prev.system}) nfsm nfsm-cli;

  #sway-unwrapped = prev.sway-unwrapped.overrideAttrs (old: {
  #  src = prev.fetchFromGitHub {
  #    owner = "swaywm";
  #    repo = "sway";
  #    rev = "6d25b100a23a17e9663cab5c286934089f2c4460";
  #    hash = "sha256-tIAHafuHAYUFVRoQQueFppqlA4FqXqdye4E+XlNBm8Y=";
  #  };
  #});

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

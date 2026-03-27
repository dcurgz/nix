{
  pkgs,
  lib,
  ...
}:
with lib;

let
  neoforge-version = "21.1.221";
in
pkgs.stdenvNoCC.mkDerivation {
  name = "neoforge-1.21.1";
  dontUnpack = true;
  dontFixup = true;

  src = pkgs.fetchurl {
    url = "https://maven.neoforged.net/releases/net/neoforged/neoforge/${neoforge-version}/neoforge-${neoforge-version}-installer.jar";
    hash = "sha256-mbyMIz7kF2MJTsoFcHSE225zVdfXf7P3IL+GCaLzAIE=";
  };

  nativeBuildInputs = with pkgs; [ jre_headless cacert ];

  installPhase = ''
    mkdir -p "$out"
    java -jar "$src" --installServer "$out"
  '';

  outputHash = "sha256-ix9Q2KFe8B/OsB8CNmvYgqTFGhMtbhZEAl2eYwccX3w=";
  outputHashMode = "recursive";
}

#let
#  url = "https://maven.neoforged.net/releases/net/neoforged/neoforge/21.1.218/neoforge-21.1.218-installer.jar";
#in
#pkgs.runCommand "neoforge-1.21.1" {
#  nativeBuildInputs = with pkgs; [
#    cacert
#    curl
#    jre_headless
#    strip-nondeterminism
#  ];
#
#  outputHash = "sha256-XzBGTaUAJzNfCSQclQ57y5jAlPbc7HK4I+JVZg0anDY=";
#  outputHashMode = "recursive";
#} ''
#  mkdir -p "$out"
#  curl "$url" -o ./installer.jar
#  java -jar ./installer.jar --installServer "$out"
#  JARFILES=$(find "$out/libraries" -name "*.jar")
#  for j in "$JARFILES"; do
#    strip-nondeterminism --type jar "$j"
#  done
#''

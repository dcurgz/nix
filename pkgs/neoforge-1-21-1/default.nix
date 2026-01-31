{
  pkgs,
  lib,
  ...
}:
with lib;

pkgs.stdenvNoCC.mkDerivation {
  name = "neoforge-1.21.1";
  dontUnpack = true;
  dontFixup = true;

  src = pkgs.fetchurl {
    url = "https://maven.neoforged.net/releases/net/neoforged/neoforge/21.1.218/neoforge-21.1.218-installer.jar";
    hash = "sha256-J9dpTWoPfkdNTGxbVcxb1ZQTIvLxWU+ZJ/+Vc9+5MyM=";
  };

  nativeBuildInputs = with pkgs; [ jre_headless cacert ];

  installPhase = ''
    mkdir -p "$out"
    java -jar "$src" --installServer "$out"
  '';

  outputHash = "sha256-XzBGTaUAJzNfCSQclQ57y5jAlPbc7HK4I+JVZg0anDY=";
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

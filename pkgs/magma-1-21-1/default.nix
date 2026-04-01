{
  pkgs,
  lib,
  ...
}:
with lib;

let
  magma-version = "21.1.67-beta";
in
pkgs.stdenvNoCC.mkDerivation {
  name = "magma-neoforge-1.21.1";
  dontUnpack = true;
  dontFixup = true;

  src = pkgs.fetchurl {
    url = "https://repo.magmafoundation.org/releases/org/magmafoundation/magma/${magma-version}/magma-${magma-version}-installer.jar";
    hash = "sha256-YvdS2ixOyqbcLi/5apqg8mx1Z2V8QTd7LoQRHTF9f0c=";
  };

  nativeBuildInputs = with pkgs; [ jre_headless cacert ];

  installPhase = ''
    mkdir -p "$out"
    java -jar "$src" --installServer "$out"
  '';

  outputHash = "sha256-tezZa5BUZEMuNd9b7N+cbMBfy6kJKFbr/5cBcNzLBQ4="; 
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

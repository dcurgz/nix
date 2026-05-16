{
  pkgs,
  lib,
  stdenv,
  fetchFromGitHub,
  darwin,
  apple-sdk_26,
}:
let
  version = "0.3.0";
in
stdenv.mkDerivation {
  pname = "vmnet-broker";
  inherit version;
  src = fetchFromGitHub {
    owner = "nirs";
    repo = "vmnet-broker";
    rev = "v${version}";
    hash = "sha256-+UStOkhqpkj2EubiY8ntARFQojRJbiMTNUIcxeyJzGU=";
  };
  nativeBuildInputs = [ darwin.sigtool ];
  buildInputs = [ apple-sdk_26 ];
  postPatch = ''
    mkdir -p include
    cat > include/version.h <<'EOF'
    #ifndef VERSION_H
    #define VERSION_H
    #define GIT_VERSION "${version}"
    #define GIT_COMMIT "release"
    #endif
    EOF
    substituteInPlace Makefile \
      --replace-fail 'codesign -f -v --entitlements entitlements.plist -s -' 'true #'
  '';
  preBuild = ''
    makeFlagsArray+=(
      "CFLAGS=-Wall -Wextra -O2 -Iinclude -mmacosx-version-min=26.0"
      "LDFLAGS=-framework CoreFoundation -framework vmnet -mmacosx-version-min=26.0"
    )
  '';
  buildFlags = [ "vmnet-broker" ];
  installPhase = ''
    mkdir -p $out/bin
    cp vmnet-broker $out/bin/
  '';
  postFixup = ''
    codesign \
      -f \
      --entitlements ${../entitlements.plist} \
      -s \
      - "$out/bin/vmnet-broker"
  '';
}

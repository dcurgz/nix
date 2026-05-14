{
  lib,
  pkgs,
  stdenv,
  fetchFromGitHub,
  meson,
  ninja,
  python3,
  darwin,
  apple-sdk_26,
}:
let
  version = "0.12.0";
in
stdenv.mkDerivation {
  pname = "vmnet-helper";
  inherit version;
  src = fetchFromGitHub {
    owner = "nirs";
    repo = "vmnet-helper";
    rev = "v${version}";
    hash = "sha256-pqkikynl5QzcPwKP3KdloZ6W5F8EfZW6arpL5jQOR9w=";
  };
  nativeBuildInputs = [
    meson
    ninja
    python3
    darwin.sigtool
  ];
  buildInputs = [ apple-sdk_26 ];
  postPatch = ''
    cat > gen-version <<'SCRIPT'
    #!/bin/sh
    cat > "$1" <<'EOF'
    #define GIT_VERSION "v${version}"
    #define GIT_COMMIT  "release"
    EOF
    SCRIPT
  '';
  postFixup = ''
    codesign -f \
      --entitlements ${../entitlements.plist} \
      -s \
      - "$out/bin/vmnet-helper"
  '';
}
